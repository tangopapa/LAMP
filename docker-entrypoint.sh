#!/bin/bash
set -eo pipefail
shopt -s nullglob

## Error checking
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

#!/bin/bash

# Start the first process
/usr/bin/mysqld_safe -DDFOREGROUND
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start MariaDB service: $status"
  exit $status
fi

# Start the second process
/usr/sbin/apachectl -DFOREGROUND -k start > /dev/null 2>&1
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Apache2 service: $status"
  exit $status
fi

# Naive check runs checks once a minute to see if either of the processes exited.

while sleep 60; do
  ps aux |grep my_first_process |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep my_second_process |grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi

exec "$@"