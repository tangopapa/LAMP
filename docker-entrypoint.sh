#!/bin/bash
set -eo pipefail
shopt -s nullglob

## Error checking
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }


# Start Apache
/usr/sbin/apachectl -DFOREGROUND -k start > /dev/null 2>&1
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Apache2 service: $status"
  exit $status
fi

# Start mysqld to config it
  mysqld_safe --skip-networking --nowatch
  mysql_options='--protocol=socket -uroot'

exec "$@"