#!/bin/bash
set -eo pipefail

if [ -z "$1" ]
then
  exec /usr/sbin/apachectl -DFOREGROUND -k start > /dev/null 2>&1
else
  exec "$@"
fi

mysqld_safe --bind-address=0.0.0.0

exec "$@"