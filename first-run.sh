#!/bin/bash

/usr/bin/mysql_install_db 
/usr/bin/mysqld_safe &
  sleep 10s
/usr/bin/mysqladmin -u root password 'mypwd'
/usr/bin/mysqladmin -u root -pmypwd -h localhost password 'mypwd'

echo "create database drupal" | mysql -u root -pmypwd

killall mysqld
sleep 10s

