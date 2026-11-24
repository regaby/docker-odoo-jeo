FROM regaby/odoo-ce:17.0
LABEL maintainer="Gabriela Rivero <regaby@gmail.com>"

USER root

# scripts to extract sources to host
COPY ./extract_dist-packages.sh /
COPY ./extract_dist-local-packages.sh /

# install wdb
RUN git clone https://github.com/jobiols/wdb.git /opt/wdb
RUN pip install --no-cache-dir --break-system-packages /opt/wdb/client
RUN pip install --no-cache-dir --break-system-packages /opt/wdb/server
RUN rm -rf /opt/wdb

USER odoo
