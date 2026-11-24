#!/usr/bin/env bash
sd build --rm=true -t regaby/odoo-ce:19.0.debug ./
# result=$?
# if [ "$result" -eq 0 ]; then
#     sd push regaby/odoo-ce:19.0.debug
# else
#     echo "Falló la creación de la imagen"
# fi
# exit $result
