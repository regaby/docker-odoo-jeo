FROM debian:buster-slim AS base-image
LABEL Odoo S.A. <info@odoo.com>

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            dirmngr \
            fonts-noto-cjk \
            gnupg \
            libssl-dev \
            node-less \
            npm \
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
# RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
#         && GNUPGHOME="$(mktemp -d)" \
#         && export GNUPGHOME \
#         && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
#         && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
#         && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
#         && gpgconf --kill all \
#         && rm -rf "$GNUPGHOME" \
#         && apt-get update  \
#         && apt-get install --no-install-recommends -y postgresql-client \
#         && rm -f /etc/apt/sources.list.d/pgdg.list \
#         && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss
RUN npm install express

# Install Odoo
ENV ODOO_VERSION 13.0
# ARG ODOO_RELEASE=20230215
# ARG ODOO_RELEASE=20230301
ARG ODOO_RELEASE=20230601
#ARG ODOO_SHA=db29fbcebf63f9f656e9445f462190ac775ee533
RUN curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
#        && echo "${ODOO_SHA} odoo.deb" | sha1sum -c - \
        && apt-get update \
        && apt-get -y install --no-install-recommends ./odoo.deb \
        && rm -rf /var/lib/apt/lists/* odoo.deb

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/

# Set permissions and Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
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
ENV Release 2021-11-29

USER root

ENV ETC_DIR /opt/odoo/etc
ENV DATA_DIR /opt/odoo/data
ENV LOG_DIR /var/log/odoo
ENV BKP_DIR /var/odoo/backups
ENV ADDONS_DIR /opt/odoo/custom-addons
ENV ODOO_RC ${ETC_DIR}/odoo.conf
RUN \
       mkdir -p ${ETC_DIR} \
    && mkdir -p ${DATA_DIR} \
    && mkdir -p ${LOG_DIR} \
    && mkdir -p ${BKP_DIR} \
    && mkdir -p ${ADDONS_DIR} \
    && chown -R odoo.odoo /opt/odoo \
    && chown -R odoo.odoo /var/odoo

# RUN curl -fsSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
RUN curl -fsSL https://bootstrap.pypa.io/pip/3.7/get-pip.py -o get-pip.py \
    && python3 get-pip.py \
    && rm get-pip.py

RUN apt-get -qq update && apt-get install -yqq --no-install-recommends \
    git \
    python3-pycurl \
    python3-dev build-essential

RUN pip3 install git+https://github.com/OCA/openupgradelib/@master

# requisites for M2Crypto
RUN apt-get update -qq
RUN apt-get install build-essential python3-dev python-dev libssl-dev swig -y -qq

RUN apt-get install python3-wand libmagickwand-dev imagemagick -y -qq

RUN pip3 install git+https://gitlab.com/filoquin/ar_mobile_parce.git
RUN pip3 install git+https://github.com/mercadolibre/python-sdk.git
RUN pip3 uninstall python-stdnum -y

# # esto agrego para que no me de error la libreria de mysql
# RUN apt-get update && apt-get install -y \
#     gcc \
#     python3-dev \
#     freetds-dev \
#     libffi-dev \
#     build-essential \
#     && rm -rf /var/lib/apt/lists/*

COPY ./requirements /req
RUN pip3 install -r /req/requirements.txt
RUN pip3 install -r /req/adhoc-odoo-argentina.txt
RUN pip3 install -r /req/adhoc-aeroo_reports.txt
RUN pip3 install -r /req/oca-geospatial.txt
RUN pip3 install -r /req/oca-rest-framework.txt
RUN pip3 install -r /req/oca-server-tools.txt

RUN rm -r /req

# crear cache para pyafipws
USER root
RUN mkdir /usr/local/lib/python3.7/dist-packages/pyafipws/cache
USER root
RUN chmod o+rw /usr/local/lib/python3.7/dist-packages/pyafipws/cache

# COPY ./fix_handshake.sh /
# USER root
# ENTRYPOINT ["/fix_handshake.sh"]
RUN sed -i 's/CipherString = DEFAULT@SECLEVEL=2/CipherString = DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf

USER odoo
