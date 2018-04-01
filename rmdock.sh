#!/bin/bash
set -eo pipefail

## Simple utility script to clean up test environment
## No error checking

docker stop $(docker ps -a -q) 
docker rm $(docker ps -a -q)
docker system prune --volumes -f
echo $(docker system df)

