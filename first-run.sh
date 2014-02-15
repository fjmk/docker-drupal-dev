#!/bin/bash

debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password mypwd'
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password mypwd'
apt-get install -y -q mysql-server php5-mysql

/usr/bin/mysqld_safe &
 sleep 10s

 echo "create database drupal" | mysql -u root -pmypwd

 echo "GRANT ALL ON drupal.* TO drupaluser@localhost IDENTIFIED BY 'drupaldbpasswd'; flush privileges; " | mysql -u root -pmypwd

killall mysqld
sleep 10s

# easy login mysql
(
cat << EOF
[client]
user = root
password = mypwd
host = localhost

[mysql]
database = drupal
EOF
) > /root/.my.cnf

# gateway == remote host for debugging
gateway=`route |grep default |awk '{print $2}'`

# easy login mysql
(
cat << EOF1
xdebug.remote_enable = 1
xdebug.remote_autostart = 0
xdebug.remote_connect_back = 0
xdebug.remote_port = 9000
xdebug.remote_host = $gateway
xdebug.profiler_enable=0
xdebug.profiler_enable_trigger=1
xdebug.profiler_output_dir="/tmp"
EOF1
) >> /etc/php5/mods-available/xdebug.ini

# enable opcache
(
cat << EOF2
opcache.memory_consumption=64
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=0
opcache.enable=1
EOF1
) >> /etc/php5/mods-available/opcache.ini
