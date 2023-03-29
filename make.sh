#!/usr/bin/env bash
#
# Script par hacer Build de las imagenes solo local
# Para hacer el build en docker pushear este repo en github

# cd jeo/11.0
# if ! ./make.sh;
# then
#     echo "Failed odoo-ce:11.0"
# 	exit 1
# else
#     echo "----------> Success odoo-ce:11.0"
# fi
#  cd ../11.0.debug
# if ! ./make.sh;
# then
#     echo "Failed odoo-ce-11.0.debug"
# 	exit 1
# else
#     echo "----------> Success odoo-ce:11.0.debug"
# fi

# cd jeo/12.0
# if ! ./make.sh;
# then
#     echo "Failed odoo-ce:12.0"
# 	exit 1
# else
#     echo "----------> Success odoo-ce:12.0"
# fi

# cd jeo/12.0.debug
# if ! ./make.sh;
# then
#     echo "Failed odoo-ce:12.0.debug"
# 	exit 1
# else
#     echo "----------> Success odoo-ce:12.0.debug"
# fi

# cd jeo/13.0
# if ! ./make.sh;
# then
#     echo "Failed odoo-ce:13.0"
# 	exit 1
# else
#     echo "----------> Success odoo-ce:13.0"
# fi

# cd ../13.0.debug
# if ! ./make.sh;
# then
#     echo "Failed odoo-ce:13.0.debug"
# 	exit 1
# else
#     echo "----------> Success odoo-ce:13.0.debug"
# fi

# cd jeo/14.0
# if ! ./make.sh;
# then
#     echo "Failed odoo-ce:14.0"
# 	exit 1
# else
#     echo "----------> Success odoo-ce:14.0"
# fi

# cd ../14.0.debug
# if ! ./make.sh;
# then
#     echo "Failed odoo-ce:14.0.debug"
# 	exit 1
# else
#     echo "----------> Success odoo-ce:14.0.debug"
# fi

# cd jeo/15.0
# if ! ./make.sh;
# then
#     echo "Failed odoo-ce:15.0"
# 	exit 1
# else
#     echo "----------> Success odoo-ce:15.0"
# fi

# cd ../15.0.debug
# if ! ./make.sh;
# then
#     echo "Failed odoo-ce:15.0.debug"
# 	exit 1
# else
#     echo "----------> Success odoo-ce:15.0.debug"
# fi

cd jeo/16.0
if ! ./make.sh;
then
    echo "Failed odoo-ce:16.0"
	exit 1
else
    echo "----------> Success odoo-ce:16.0"
fi

cd ../16.0.debug
if ! ./make.sh;
then
    echo "Failed odoo-ce:16.0.debug"
	exit 1
else
    echo "----------> Success odoo-ce:16.0.debug"
fi


