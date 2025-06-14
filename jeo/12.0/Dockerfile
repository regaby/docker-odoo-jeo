FROM debian:stretch-slim AS base-image
MAINTAINER Odoo S.A. <info@odoo.com>

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Use backports to avoid install some libs with pip
RUN echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/backports.list

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            dirmngr \
            fonts-noto-cjk \
            gnupg \
            libssl1.0-dev \
            node-less \
            python3-num2words \
            python3-pip \
            python3-phonenumbers \
            python3-pyldap \
            python3-qrcode \
            python3-renderpm \
            python3-setuptools \
            python3-slugify \
            python3-vobject \
            python3-watchdog \
            python3-xlrd \
            python3-xlwt \
            xz-utils \
        && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
        && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
        && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# install latest postgresql-client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
        && GNUPGHOME="$(mktemp -d)" \
        && export GNUPGHOME \
        && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
        && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
        && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
        && gpgconf --kill all \
        && rm -rf "$GNUPGHOME" \
        && apt-get update  \
        && apt-get install --no-install-recommends -y postgresql-client \
        && rm -f /etc/apt/sources.list.d/pgdg.list \
        && rm -rf /var/lib/apt/lists/*

# Install rtlcss (on Debian stretch)
RUN echo "deb http://deb.nodesource.com/node_8.x stretch main" > /etc/apt/sources.list.d/nodesource.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/nodejs.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update \
    && apt-get install --no-install-recommends -y nodejs \
    && npm install -g rtlcss \
    && rm -rf /var/lib/apt/lists/*

# Install Odoo
ENV ODOO_VERSION 12.0
ARG ODOO_RELEASE=20200709
#ARG ODOO_SHA=ca4a7485b0b75850ffe1458a8f3266839400a501
RUN curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
#        && echo "${ODOO_SHA} odoo.deb" | sha1sum -c - \
        && apt-get update \
        && apt-get -y install --no-install-recommends ./odoo.deb \
        && rm -rf /var/lib/apt/lists/* odoo.deb

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/

# Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8072

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]

###############################################################################
############################ Fin de base image ################################
###############################################################################

FROM base-image
LABEL maintainer="Gabriela Rivero <regaby@gmail.com>"
ENV Release 2020-07-09

USER root

COPY ./entrypoint.sh /

# config
RUN mkdir -p /opt/odoo/etc \
    && chown -R odoo /opt/odoo/etc
ENV ODOO_RC /opt/odoo/etc/odoo.conf

# filestore
RUN mkdir -p /opt/odoo/data \
    && chown -R odoo /opt/odoo/data

# log
RUN mkdir -p /var/log/odoo \
    && chown -R odoo /var/log/odoo

# backup
RUN mkdir -p /var/odoo/backups \
    && chown -R odoo /var/odoo/backups

# addons
RUN mkdir -p /opt/odoo/custom-addons \
    && chown -R odoo /opt/odoo/custom-addons

# Other requirements, useful tools and recommendations to run Odoo (libldap2-dev
# libsasl2-dev re recommended by odoo here https://www.odoo.com/documentation/11.0/setup/install.html). libcups2-dev is for aeroo. Then install locales and later clean everything
RUN apt-get -qq update && apt-get install -yqq --no-install-recommends \
    git \
    python3-dev build-essential

#    ssh wget unzip iputils-ping \
#    libldap2-dev libsasl2-dev \
#    libcups2-dev \
#    locales \
#    && locale-gen en_US.UTF-8 && update-locale \
#    && locale-gen es_AR.UTF-8 && update-locale \
#    && echo 'LANG="en_US.UTF-8"' > /etc/default/locale \
#    && pip3 install --no-cache-dir --upgrade pip setuptools

RUN pip3 install git+https://github.com/OCA/openupgradelib/@master
# num2words wheel vobject qrcode
#    && apt-get purge -yqq build-essential '*-dev' \
#    && apt-get -yqq autoremove \
#    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# requisites for M2Crypto
RUN apt-get update -qq
RUN apt-get install build-essential python3-dev python-dev libssl-dev swig -y -qq

COPY ./requirements /req
RUN pip3 install -r /req/requirements.txt
RUN pip3 install -r /req/adhoc-account-payment.txt
RUN pip3 install -r /req/adhoc-aeroo_reports.txt
RUN pip3 install -r /req/adhoc-argentina-reporting.txt
RUN pip3 install -r /req/adhoc-odoo-argentina.txt
RUN pip3 install -r /req/adhoc-argentina-sale.txt
RUN pip3 install -r /req/adhoc-miscellaneous.txt
RUN pip3 install -r /req/adhoc-odoo-support.txt
RUN pip3 install -r /req/adhoc-product.txt
RUN pip3 install -r /req/adhoc-website.txt
RUN pip3 install -r /req/oca-server-tools.txt
RUN pip3 install -r /req/oca-web.txt
RUN pip3 install -r /req/oca-rest-framework.txt
RUN pip3 install -r /req/oca-partner-contact.txt
RUN pip3 install -r /req/odoo-com.txt
RUN pip3 install -r /req/fecr.txt
RUN pip3 install -r /req/meli-requirements.txt
#RUN pip3 install -r /req/adhoc-reporting-engine.txt # esto no anda por el pycups
RUN rm -r /req

# crear cache para pyafipws
RUN mkdir /usr/local/lib/python3.5/dist-packages/pyafipws/cache
RUN chmod o+rw /usr/local/lib/python3.5/dist-packages/pyafipws/cache

# create directory for odoo files
ENV ETC_DIR /opt/odoo/etc
ENV DATA_DIR /opt/odoo/data
ENV CUSTOM_ADDONS /opt/odoo/custom-addons
ENV EXTRA_ADDONS /opt/odoo/extra-addons
RUN mkdir -p /opt/odoo \
    && mkdir -p ${ETC_DIR} \
    && mkdir -p ${DATA_DIR} \
    && mkdir -p ${CUSTOM_ADDONS} \
    && mkdir -p ${EXTRA_ADDONS} \
    && chown -R odoo.odoo /opt/odoo

# Definir config, log, data_dir y entrypoint.sh
COPY ./odoo.conf $ETC_DIR
RUN chown odoo /opt/odoo/etc/odoo.conf

COPY ./resources/entrypoint.sh ./entrypoint.sh
ENV ODOO_CONF /opt/odoo/etc/odoo.conf

# Set the default config file
ENV ODOO_RC $ETC_DIR/odoo.conf

CMD ["odoo"]

# Variables used by the launch scripts
ENV \
    DB_TEMPLATE=template1 \
    PGUSER=odoo \
    PGPASSWORD=odoo \
    PGHOST=db \
    ODOO_SERVER=odoo \
    ODOO_CONF=/opt/odoo/etc/odoo.conf \
    FIXDBS=False \
    WAIT_PG=True \
    PG_MAX_CONNECTIONS=100 \
    # odoo conf variables
    MAX_CRON_THREADS=1 \
    SMTP_SERVER=localhost \
    SMTP_PORT=25 \
    SMTP_SSL=False \
    SMTP_USER=False \
    SMTP_PASSWORD=False \
    UNACCENT=True \
    WORKERS=6 \
    ADMIN_PASSWORD=admin \
    DISABLE_SESSION_GC=false \
    PROXY_MODE=True \
    WITHOUT_DEMO=True \
    DBFILTER=.* \
    LIMIT_TIME_CPU=1600 \
    LIMIT_TIME_REAL=3200 \
    LIMIT_MEMORY_HARD=2684354560 \
    LIMIT_MEMORY_SOFT=2147483648 \
    AEROO_DOCS_HOST=aeroo \
    AFIP_HOMO_PKEY_FILE=/opt/odoo/backups/homo.pkey \
    AFIP_HOMO_CERT_FILE=/opt/odoo/backups/homo.cert \
    AFIP_PROD_PKEY_FILE=/opt/odoo/backups/prod.pkey \
    AFIP_PROD_CERT_FILE=/opt/odoo/backups/prod.cert

ENTRYPOINT ["/entrypoint.sh"]

USER odoo


USER root

## Oracle Cliente
## https://stackoverflow.com/questions/55852183/error-using-oracle-instant-client-docker-image
# 1. Install dependencies
FROM node:8.15 as cache-package

# COPY package.json /srv/src/package.json
# WORKDIR /srv/src

RUN yarn install

# 2.
FROM node:8.15 as builder

# 1. Update everything on the box
RUN apt-get update && \
      apt-get install sudo
#RUN apk --update add libaio bc net-tools
RUN sudo apt-get install unzip
RUN sudo apt-get install wget
RUN sudo apt-get install git

# 3. Install oracle client
RUN mkdir -p /opt/oracle
# 3.1 Get oracle client
WORKDIR /opt/oracle

RUN wget -O /opt/oracle/instantclient_19_6_linux.zip https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-basic-linux.x64-19.6.0.0.0dbru.zip
RUN sudo unzip /opt/oracle/instantclient_19_6_linux.zip

# 3.2 Configure oracle client to work with node
RUN sudo sh -c "echo /opt/oracle/instantclient_19_6_linux > /etc/ld.so.conf.d/oracle-instantclient.conf"
RUN sudo cat /etc/ld.so.conf.d/oracle-instantclient.conf



FROM node:8.15

RUN apt-get update && \
      apt-get install sudo
RUN sudo apt-get install libaio1

# RUN mkdir -p /srv/src/logs
# RUN mkdir -p /srv/logs
RUN mkdir -p /opt/oracle

# 4. Set the working directory

# 5. Copy our project & install our dependencies
# COPY --from=cache-package /srv/src /srv/src

# COPY --from=builder /opt/oracle/instantclient_19_6_linux /opt/oracle/instantclient_19_6_linux
COPY --from=builder /etc/ld.so.conf.d/oracle-instantclient.conf /etc/ld.so.conf.d/oracle-instantclient.conf

RUN sudo ldconfig

RUN ln -sf /usr/share/zoneinfo/WET /etc/localtime

# COPY . /srv/src

# WORKDIR /srv/src

# 6. Start the app
CMD yarn start


USER odoo
