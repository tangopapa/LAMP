#!/bin/bash
set -eo pipefail

SITE=example
OPENSSL=openssl-1.0.1d

## Error checking
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

make_cert () {
 openssl req \
-new \
-newkey rsa:4096 \
-days 365 \
-nodes \
-x509 \
-subj "/C=US/ST=VA/L=Upperville/O=dtool/CN=www.$SITE.com" \
-keyout www.$SITE.com.key \
-out www.$SITE.com.cert
}

## Enable SSL module
a2enmod ssl

## Restart Apache to effect these changes
## Check to see if apache2 has started; if not, start it
if [[ -z $(pgrep apache2) ]]; then 
    service apache2 start
else
    service apache2 restart
fi

## Apache has an SSL template; let's use that
a2ensite default-ssl

## Restart Apache to effect these changes
## Check to see if apache2 has started; if not, start it
if [[ -z $(pgrep apache2) ]]; then 
    service apache2 start
else
    service apache2 reload
fi

## Create a new directory where we can store the private key and certificate
mkdir -p /etc/apache2/ssl
cd /etc/apache2/ssl
make_cert
chmod 600 /etc/apache2/ssl/*

## Create directories sshd requires
mkdir -p /run/sshd

## Modify default-ssl.conf
sed -i.bak "/^\s*ServerAdmin\s*webmaster@localhost/a\ServerName ${SITE}.com:443" /etc/apache2/sites-enabled/default-ssl.conf
sed -i.bak "/^\s*SSLCertificateFile/c\SSLCertificateFile /etc/apache2/ssl/www.$SITE.com.cert"  /etc/apache2/sites-enabled/default-ssl.conf
sed -i.bak "/^\s*SSLCertificateKeyFile/c\SSLCertificateKeyFile /etc/apache2/ssl/www.$SITE.com.key"  /etc/apache2/sites-enabled/default-ssl.conf
rm -rf /etc/apache2/sites-enabled/*bak

echo /etc/apache2/sites-enabled/default-ssl.conf

## Error checking
cd /
z=$(find . -print | grep  'bin/openssl')
echo "Where is openssl?"
echo -e $z
echo "***********************************************************************************************************************"
echo /etc/apache2/sites-enabled/default-ssl.conf

## Modify sshd.config banner greeting
## sed -i.bak "/^#Banner none/c\Banner *** WELCOME TO DOCKTER-TOM ***" /etc/ssh/sshd.config
## rm -rf *bak

## This is a soft link
if [ -e /etc/apache2/sites-available/default-ssl.conf ]; then
rm -rf /etc/apache2/sites-available/default-ssl.conf
fi
ln -s /etc/apache2/sites-enabled/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf

## Create supervisord log file
mkdir -p /var/log/supervisor
touch /var/log/supervisor/supervisord.log

## exec /usr/bin/supervisord -n                                        
## while true; do sleep 1; done
## exec "$@"