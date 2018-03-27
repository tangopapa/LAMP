#!/bin/bash
set -eo pipefail

/usr/sbin/apachectl -DFOREGROUND -k start

exec "$@"