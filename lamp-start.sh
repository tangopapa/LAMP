#!/bin/bash
#
#  This file is the first command in Jenkins pipeline - sets bash debug mode & kicks off LAMP container build

set -eo pipefail

docker build -t "tangopapa/lamp" .
