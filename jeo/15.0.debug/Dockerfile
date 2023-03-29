FROM regaby/odoo-ce:15.0
LABEL maintainer="Gabriela Rivero <regaby@gmail.com>"

USER root

# scripts to extract sources to host
COPY ./extract_dist-packages.sh /
COPY ./extract_dist-local-packages.sh /

# install wdb
RUN pip3 install wdb

USER odoo
