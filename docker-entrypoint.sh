#!/bin/bash
set -eo pipefail
shopt -s nullglob

## Error checking
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }


## Start Apache
/usr/sbin/apachectl -DFOREGROUND -k start &
status=$?
## apachectl script returns a 0 exit value on success, and >0 if an error occurs
if [ $status -ne 0 ]; then
  echo "Failed to start Apache2 service: $status"
  exit $status
fi
exec "$@"