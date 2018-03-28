#!/bin/bash
#
#  This file is the first command in Jenkins pipeline - sets bash debug mode & kicks off lamp container build

set -eo pipefail

docker build -t lamp .
