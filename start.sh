#!/bin/bash

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

# Configure mysql-client
cat <<EOF1 >/etc/mysql/my.cnf
[client]
port            = $DB_PORT_3306_TCP_PORT
host            = $DB_PORT_3306_TCP_ADDR
EOF1

cat <<EOF2 >/root/.my.cnf
[client]
user = $DB_ENV_MYSQL_USER
password = $DB_ENV_MYSQL_PASSWORD

[mysql]
database = $DB_ENV_MYSQL_DATABASE
EOF2

supervisord
