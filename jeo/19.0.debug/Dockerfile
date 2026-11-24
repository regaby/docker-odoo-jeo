FROM regaby/odoo-ce:19.0
LABEL maintainer="Jorge Obiols <jorge.obiols@gmail.com>"

USER root

# # scripts to extract sources to host
# COPY ./extract_site-packages.sh /
# COPY ./extract_src.sh /

# # install wdb
# RUN /odoo/venv/bin/pip install --no-cache-dir \
#     https://github.com/jobiols/wdb/archive/refs/heads/master.tar.gz#subdirectory=client

# # sin esto no anda el wdb
# RUN pip install --break-system-packages debugpy


# USER odoo

######################################

# scripts to extract sources to host
# USER odoo
# USER root

COPY ./extract_dist-packages.sh /
COPY ./extract_dist-local-packages.sh /

RUN apt-get update && apt-get install -y git

# install wdb
# RUN git clone https://github.com/jobiols/wdb.git /opt/wdb \
#     && pip install --no-cache-dir --break-system-packages /opt/wdb/client \
#     && rm -rf /opt/wdb
# install wdb
RUN pip install wdb --break-system-packages

# sin esto no anda el wdb
RUN pip install --break-system-packages debugpy

USER odoo
