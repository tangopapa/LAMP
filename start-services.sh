#!/bin/bash
set -eo pipefail

## Error checking
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

# Start apache2
/usr/sbin/apachectl -DFOREGROUND -k start > /dev/null 2>&1
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Apache2 service: $status"
  exit $status
fi

exec "$@"
