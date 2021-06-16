#!/bin/bash
echo "Fix error SSLHandShake httplib2"
sed -i 's/CipherString = DEFAULT@SECLEVEL=2/CipherString = DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf
