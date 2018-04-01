#!/bin/bash
set -eo pipefail

SITE=example
OPENSSL=openssl-1.0.1d

## Error checking
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }


## Let's replace current version of openssl w/ heartbleed vulnerable version: openssl-1.0.1d
## It ends up in /usr/local/bin/
mkdir -p /opt
cd /opt
wget https://www.openssl.org/source/old/1.0.1/$OPENSSL.tar.gz
if [ ! -f /opt/$OPENSSL.tar.gz ]; then
    wget https://www.openssl.org/source/old/1.0.1/$OPENSSL.tar.gz
fi

tar -xvzf $OPENSSL.tar.gz
cd $OPENSSL
./config --prefix=/usr
make 
make install_sw
rm -rf $OPENSSL*

make_cert() {
openssl req \
-new \
-newkey rsa:4096 \
-days 365 \
-nodes \
-x509 \
-subj "/C=US/ST=Virginia/L=Somewhere/O=Sometime/CN=www.$SITE.com" \
-keyout www.$SITE.com.key \
-out www.$SITE.com.cert
}

## Create directories sshd requires
mkdir -p /run/sshd

## Modify sshd.config banner greeting
sed -i.bak "/^#Banner none/c\Banner *** WELCOME TO DOCKTER-TOM ***" /etc/ssh/sshd_config
sed -i.bak "/^#PermitRootLogin prohibit-password/c\PermitRootLogin yes" /etc/ssh/sshd_config
rm -rf *bak
service sshd restart

## Enable SSL module
a2enmod ssl

## Apache has an SSL template; let's use that
a2ensite default-ssl

## Create a new directory where we can store the private key and certificate
mkdir -p /etc/apache2/ssl
cd /etc/apache2/ssl
make_cert
chmod 600 /etc/apache2/ssl/*


## Modify default-ssl.conf
sed -i.bak "/^\s*ServerAdmin\s*webmaster@localhost/a\ServerName ${SITE}.com:443" /etc/apache2/sites-enabled/default-ssl.conf
sed -i.bak "/^\s*SSLCertificateFile/c\SSLCertificateFile /etc/apache2/ssl/www.$SITE.com.cert"  /etc/apache2/sites-enabled/default-ssl.conf
sed -i.bak "/^\s*SSLCertificateKeyFile/c\SSLCertificateKeyFile /etc/apache2/ssl/www.$SITE.com.key"  /etc/apache2/sites-enabled/default-ssl.conf
rm -rf /etc/apache2/sites-enabled/*bak

## This is a soft link
if [ -e /etc/apache2/sites-available/default-ssl.conf ]; then
rm -rf /etc/apache2/sites-available/default-ssl.conf
fi
ln -s /etc/apache2/sites-enabled/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf

## Create supervisord log file
mkdir -p /var/log/supervisor
touch /var/log/supervisor/supervisord.log
