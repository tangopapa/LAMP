#!/bin/bash

#######################################
# Bash script to non-interactively install a LAMP stack + Wordpress. Tested on Debian Stretch.
# Tom Porter
# v1.0
#######################################

# Error checking
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }


# Update packages system
apt-get update  -y

## Install Apache
apt-get install apache2 libapache2-mod-php7.0 -y
printf "Finished Installing Apache\n"

## Install PHP
apt-get install php7.0 php7.0-mysql  -y
printf "Finished Installing PHP\n"

## Install Mysql non-interactively
export DEBIAN_FRONTEND="noninteractive"
sudo debconf-set-selections <<< 'mariadb-server-10.0 mariadb-server/root_password password krumpli6'
sudo debconf-set-selections <<< 'mariadb-server-10.0 mariadb-server/root_password_again password krumpli6'
apt-get install mariadb-client mariadb-server -y

## Setup WP database
mysql -u root  <<EOF 
DROP USER IF EXISTS wp_user;
CREATE USER 'wp_user' IDENTIFIED BY 'wp_password'; 
DROP DATABASE IF EXISTS wp_database; 
CREATE DATABASE wp_database; 
GRANT ALL ON wp_database.* TO 'wp_user'; 
FLUSH PRIVILEGES;
EOF

printf "Finished Installing MariaDB\n"
sleep 2


# Install Wordpress
cd /opt || exit
wget https://wordpress.org/latest.tar.gz
tar xpf latest.tar.gz
rm -rf latest.tar.gz
rm -rf /var/www/html
cp -r wordpress /var/www/html
rm -rf wordpress

# Permissions
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# Restart Apache
service apache2 restart