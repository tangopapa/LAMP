#!/bin/bash
set -eo pipefail
shopt -s nullglob

## Error checking
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

#!/bin/bash

# Start the first process
service mysql start -D
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start MariaDB service: $status"
  exit $status
fi

# Start the second process
service apache2 start -D
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Apache2 service: $status"
  exit $status
fi

exec "$@"