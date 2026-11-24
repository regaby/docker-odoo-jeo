#!/usr/bin/env bash
sudo docker build --rm=true --build-arg ODOO_RELEASE=$(date -u +%Y%m%d) -t regaby/odoo-ce:19.0 ./
# result=$?
# if [ "$result" -eq 0 ]; then
#     sd push regaby/odoo-ce:19.0
# else
#     echo "Falló la creación de la imagen"
# fi
# exit $result

# 2.39 Gb 10/10/2025
#