#!/bin/bash

set -eo pipefail

#######################################
# Clean up after testing Bash script to non-interactively install a LAMP stack + Wordpress. Tested on Debian Stretch.
# Tom Porter
# v1.0
#######################################

## Error checking
yell() { printf "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

apt-get remove apache2 libapache2-mod-php7.0 php7.0 php7.0-mysql mariadb-client mariadb-server mysql-common -y
apt-get purge apache2 libapache2-mod-php7.0 php7.0 php7.0-mysql mariadb-client mariadb-server mysql-common -y
apt-get autoremove -y
apt-get autoclean

## Clean up /var/cache/debconf/passwords.dat
echo PURGE | debconf-communicate mysql-server
echo PURGE | debconf-communicate mariadb-server-10.0

## Remove database that this install leaves behind
rm -rf  /var/lib/mysql/wp_database

## Remove Wordpress /html directory
rm -rf /var/www/html

printf "\n\n"
ps waux | grep "mysqld"
ps waux | grep "apache"
printf "\n\n"
printf "All clean!\n"
