#!/bin/bash

if [ ! -d /var/lib/mysql/mysql ]; then
  /first-run.sh
fi

supervisord
