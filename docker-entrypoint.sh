#!/bin/bash
set -eo pipefail

#mysqld_safe --bind-address=0.0.0.0 && /usr/sbin/apachectl -DFOREGROUND -k start

exec "$@"