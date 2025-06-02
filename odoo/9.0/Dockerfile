FROM ubuntu:xenial
MAINTAINER Jorge Obiols <jorge.obiols@gmail.com>

# segun odoo esta version sigue siendo la recomendable https://github.com/odoo/odoo/wiki/Wkhtmltopdf, la 12.2.1 y las podemos encontrar acá https://wkhtmltopdf.org/downloads.html

# ENV WKHTMLTOX_X64 https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.trusty_amd64.deb

# Retrieve the target architecture to install the correct wkhtmltopdf package
ARG TARGETARCH

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            node-less \
            node-clean-css \
            python-pyinotify \
            python-pip \
            python-renderpm 
            # not anymore on ubuntu 16.04
            # python-support
# RUN set -x; \
#         curl -o wkhtmltox.deb -SL ${WKHTMLTOX_X64} \
#         && dpkg --force-depends -i wkhtmltox.deb \
#         && apt-get -y install -f --no-install-recommends \
#         && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
#         && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

#     if [ -z "${TARGETARCH}" ]; then \
#         TARGETARCH="$(dpkg --print-architecture)"; \
#     fi; \
#     WKHTMLTOPDF_ARCH=${TARGETARCH} && \
#     case ${TARGETARCH} in \
#     "amd64") WKHTMLTOPDF_ARCH=amd64 && WKHTMLTOPDF_SHA=967390a759707337b46d1c02452e2bb6b2dc6d59  ;; \
#     "arm64")  WKHTMLTOPDF_SHA=90f6e69896d51ef77339d3f3a20f8582bdf496cc  ;; \
#     "ppc64le" | "ppc64el") WKHTMLTOPDF_ARCH=ppc64el && WKHTMLTOPDF_SHA=5312d7d34a25b321282929df82e3574319aed25c  ;; \
#     esac \
#     && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_${WKHTMLTOPDF_ARCH}.deb \
#     && echo ${WKHTMLTOPDF_SHA} wkhtmltox.deb | sha1sum -c - \
#     && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
#     && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# RUN curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
RUN curl -o wkhtmltox.deb -sSL github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.trusty_amd64.deb \
        # && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
        && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install Odoo
ENV ODOO_VERSION 9.0
# revertimos por error con Unknown path: /base/rng/view.rng y repositorio enterprise no en ultima version
# ENV ODOO_RELEASE 20190401

# 2025-05-24 15:47:53,089 1 INFO ? openerp: OpenERP version 9.0c-20180827
# ENV ODOO_RELEASE 20180801
ENV ODOO_RELEASE 20180901

RUN set -x; \
        curl -o odoo.deb -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}c.${ODOO_RELEASE}_all.deb \
        && dpkg --force-depends -i odoo.deb \
        && apt-get update \
        && apt-get -y install -f --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* odoo.deb

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./openerp-server.conf /etc/odoo/
RUN chown odoo /etc/odoo/openerp-server.conf

# Mount /opt/odoo/data to allow restoring filestore and /mnt/extra-addons for users addons
RUN mkdir -p /mnt/extra-addons \
        && chown -R odoo /mnt/extra-addons
VOLUME ["/opt/odoo/data", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071

# Set the default config file
ENV OPENERP_SERVER /etc/odoo/openerp-server.conf

# RUN apt-get -qq update && apt-get install -yqq --no-install-recommends \
#         python-setuptools \
#         python-dev build-essential \
#         git 
# Instala git y dependencias del sistema necesarias para compilar extensiones (como lxml)
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    python-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libffi-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get -qq update && apt-get install -yqq --no-install-recommends \
        python-setuptools \
        libjpeg-dev

# RUN pip install --upgrade pip setuptools wheel

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["openerp-server"]

# RUN pip install --upgrade pip

run pip install lxml==3.5.0

COPY ./requirements /req
# RUN pip3 install -r /req/requirements.txt
# RUN pip install -r /req/adhoc-aeroo_reports.txt

# RUN pip install git+https://github.com/edgewall/genshi@stable/0.7.x

RUN pip install genshi==0.7

RUN pip install --no-deps git+https://github.com/adhoc-dev/aeroolib@py2.x

RUN pip install git+https://github.com/aeroo/currency2text.git

# RUN pip install -r /req/adhoc-odoo-argentina.txt

RUN pip install idna==2.7
RUN pip install ipaddress==1.0.22
RUN pip install asn1crypto==0.24.0
# RUN pip install cffi==1.11.5
RUN pip install --only-binary=:all: --no-cache-dir cffi==1.11.5
RUN pip install --no-deps cryptography==2.3.1     


# RUN pip install M2Crypto==0.22.6rc4
USER root
RUN apt-get install swig \
libssl-dev \
-y -qq
USER odoo


RUN pip install --no-deps pyOpenSSL==18.0.0



RUN pip install httplib2==0.9.1

RUN pip install aenum==2.1.2
RUN pip install enum34==1.1.6

RUN pip install fpdf==1.7.2
RUN pip install dbf==0.97.11
RUN pip install Pillow==3.1.2

RUN pip install six==1.10.0

RUN pip install M2Crypto==0.23.0
# RUN pip install cryptography==37.0.4
# RUN pip install git+https://github.com/4/pysimplesoap@e1453f385cee119bf8cfb53c763ef212652359f5
RUN pip install PySimpleSOAP==1.8.14
# RUN pip install git+https://github.com/comunidad-odoo-misiones/pyafipws@py3k_2025

# RUN pip install git+https://github.com/reingart/pyafipws@py2exe
RUN pip install git+https://github.com/fundacion-mirgor/pyafipws@py2exe

RUN pip install future==0.18.2

# RUN pip install bcrypt==3.1.4
# RUN pip install --no-deps pysftp==0.2.9


# RUN pip3 install -r /req/oca-geospatial.txt
# RUN pip3 install -r /req/oca-rest-framework.txt
# RUN pip3 install -r /req/oca-server-tools.txt

# RUN rm -r /req

# crear cache para pyafipws
USER root
RUN mkdir /var/lib/odoo/.local/lib/python2.7/site-packages/pyafipws/cache
USER root
RUN chmod o+rw /var/lib/odoo/.local/lib/python2.7/site-packages/pyafipws/cache

# COPY ./fix_handshake.sh /
# USER root
# ENTRYPOINT ["/fix_handshake.sh"]
RUN sed -i 's/CipherString = DEFAULT@SECLEVEL=2/CipherString = DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf

USER odoo
