#!/bin/bash
################################################################
# Extrae los odoo packages de la imagen al host para desarrollo
# revision 2023-11-17

# rm -r /mnt/dist-packages/*
# cp -r /usr/lib/python3/dist-packages/* /mnt/dist-packages/

# cp -r /odoo/venv/lib/python3.12/site-packages/* /mnt/site-packages/

cp -r /odoo/venv/lib/python3.12/site-packages/* /mnt/dist-packages/


