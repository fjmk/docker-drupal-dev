#!/bin/bash

if [ ! -d /var/lib/mysql/mysql ]; then
  /first-run.sh
fi

#make sure xdebug remote host is set
# remove xdebug.remote_host line from xdebug.ini
sed -i '/xdebug.remote_host/d' /etc/php5/mods-available/xdebug.ini

# gateway == remote host for debugging
gateway=`route |grep default |awk '{print $2}'`

(
cat << EOF1
xdebug.remote_host = $gateway
EOF1
) >> /etc/php5/mods-available/xdebug.ini




supervisord
