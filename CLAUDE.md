# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of standalone `Dockerfile`s (and their build/support scripts) for Odoo-related Docker images pushed to Docker Hub under `regaby/*` and `jobiols/*`. There is no application code, no test suite, and no package manifest at the repo level — each subdirectory is an independent image build context.

## Layout

- `jeo/<version>/` — the actively maintained Odoo image line (`regaby/odoo-ce:<version>`), one directory per Odoo version (8.0 through 19.0, plus a few `.ou` variants for specific clients). Latest work is on 17.0/18.0/19.0.
- `jeo/<version>.debug/` — a debug image `FROM regaby/odoo-ce:<version>`, layering in `wdb`/`debugpy` and (on older versions) scripts to extract `dist-packages`/`dist-local-packages` to the host for local debugging. Must be built **after** its base `jeo/<version>` image.
- `odoo/8.0/`, `odoo/9.0/`, `odoo/9.0.ou/` — legacy/older image line, kept for history; not actively developed.
- `aeroo/` — image for the Aeroo Docs report-conversion server (`jobiols/aeroo-docs`).
- `dbtools/` — image bundling Postgres client tools to restore/deactivate a backup into a running Postgres container (`regaby/dbtools`).

Each version directory is self-contained and typically includes:
- `Dockerfile` — the image definition.
- `make.sh` — the build (and sometimes push) command for that one image.
- `entrypoint.sh` — container entrypoint (Odoo images only).
- `odoo.conf` — default Odoo config copied into the image.
- `wait-for-psql.py` — waits for Postgres to accept connections before starting Odoo.
- `requirements/` — one or more `pip` requirement files (`requirements.txt`, `adhoc-odoo-argentina.txt`, `adhoc-aeroo_reports.txt`, `oca-*.txt`, etc.) copied into the image and installed; which files actually get installed is decided line-by-line in the `Dockerfile`, not by directory convention — check the `Dockerfile` before assuming a requirements file is in use.

## Building an image

Build a single image by `cd`-ing into its directory and running its script:

```bash
cd jeo/19.0
./make.sh
```

`make.sh` scripts call either `sudo docker build` (newer versions, which also pass `--build-arg ODOO_RELEASE=$(date -u +%Y%m%d)` to bust the layer cache and pin a nightly release date) or the local `sd` wrapper (`sd build --rm=true -t <image>:<tag> ./`, and `sd push ...` to push) used throughout the older/legacy image scripts. Push lines are generally left commented out in `make.sh`; pushing is a manual, deliberate step, not something the scripts do automatically.

The root `make.sh` is a scratch orchestrator that `cd`s into several `jeo/<version>` and `jeo/<version>.debug` dirs and runs their `make.sh` in sequence, aborting on the first failure. Most of its stanzas are commented out at any given time — check what's actually enabled before assuming it builds "everything"; treat it as a template to enable/disable per version rather than a script that's always run in full.

To build a `.debug` variant, build the non-debug image for that version first (the debug `Dockerfile` starts `FROM regaby/odoo-ce:<version>`).

## Dockerfile patterns by era

Two generations of `jeo` Dockerfile coexist; check which one a given version uses before editing it:

- **Older (~13.0–17.0):** single/two-stage build on `debian:buster-slim` or `ubuntu:noble`, installs Odoo from the official `.deb` package fetched from `nightly.odoo.com` (pinned via `ARG ODOO_RELEASE=<date>` and formerly a `sha1sum` check), then a second `FROM base-image` stage adds Argentina-specific pip requirements, OCA modules, and misc patches (e.g. relaxing OpenSSL cipher `SECLEVEL` for legacy TLS handshakes).
- **Newer (18.0+, e.g. 19.0):** explicit multi-stage `builder`/`runtime` split on `ubuntu:noble`. The builder stage creates a Python venv, `git clone --depth 1 --branch <version>` of the Odoo source directly from GitHub, and `pip install`s core + extra requirements into the venv. The runtime stage installs only runtime (non-`-dev`) system libs, creates the `odoo` user/group at fixed uid/gid `1100`, and copies the venv + Odoo source + entrypoint/config from the builder stage — keeping the final image slim.

Both eras: install `wkhtmltopdf` from a pinned GitHub release with an architecture-aware SHA check, install a PostgreSQL client from the official `apt.postgresql.org` repo, expose `8069`/`8071`/`8072`, run as the non-root `odoo` user, and use `ENTRYPOINT ["/entrypoint.sh"]`.

## entrypoint.sh pattern (Odoo images)

Shared logic across versions:
1. Resolve DB connection params from `HOST`/`PORT`/`USER`/`PASSWORD` env vars (falling back to legacy `DB_ENV_*`/linked-container vars), unless already set in `$ODOO_RC` (the copied-in `odoo.conf`).
2. Run `wait-for-psql.py` with those args before starting Odoo, so the container doesn't crash-loop while Postgres is still starting.
3. `exec odoo-bin "$@" "${DB_ARGS[@]}"` (or pass through directly for non-Odoo commands / `scaffold`).

## Working in this repo

- There's no build/lint/test command to run — verifying a change means building the affected image (`./make.sh` in that version's directory) and, for behavioral changes, running the resulting container against a Postgres instance.
- Version directories are largely independent copies with accumulated drift (compare with `diff jeo/<a>/Dockerfile jeo/<b>/Dockerfile` before porting a fix across versions — don't assume they're structurally identical).
- Requirement files under `requirements/` are per-version and per-client (Argentina-specific AFIP/electronic-invoicing libs, Aeroo reports, OCA modules); when adding a new version directory, check the previous version's `requirements/` and `Dockerfile` `pip install -r` lines together to see which files are actually wired in.
