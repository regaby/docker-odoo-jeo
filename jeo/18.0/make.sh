#!/usr/bin/env bash
sd build --rm=true -t regaby/odoo-ce:18.0 ./
# result=$?
# if [ "$result" -eq 0 ]; then
    # sd push regaby/odoo-ce:18.0
# else
    # echo "Falló la creación de la imagen"
# fi
# exit $result
