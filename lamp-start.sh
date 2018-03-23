#!/bin/bash
#
#  This file is the first command in Jenkins pipeline - sets bash debug mode & kicks off lamp container build

set -e

docker build -t lamp .
