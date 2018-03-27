#!/bin/bash
set -eo pipefail

mysqld_safe --bind-address=0.0.0.0

exec "$@"