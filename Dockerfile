FROM debian:stretch-slim
LABEL maintainer="tom@frogtownroad.com"

## ENV user=dockter-tom
## RUN groupadd -r ${user} && useradd -r -l -M ${user} -g ${user} 

## Update packages
RUN apt-get update  -y

## Install supplementary packages
RUN apt-get install wget supervisor openssh-server -y  && \
mkdir -p /var/log/supervisor

## Install Apache
RUN apt-get install apache2 libapache2-mod-php7.0 -y

## Install PHP
RUN apt-get install php7.0 php7.0-mysql  -y

## Install wget - moved to PHP

## Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

## Install Mysql non-interactively
RUN export DEBIAN_FRONTEND="noninteractive"                                                                  && \
echo mariadb-server-10.0 mariadb-server/root_password password tmpsetup | debconf-set-selections             && \
echo mariadb-server-10.0 mariadb-server/root_password_again password tmpsetup | debconf-set-selections       && \
apt-get install mariadb-client mariadb-server -y


RUN mysqld_safe & until mysqladmin ping >/dev/null 2>&1; do sleep 1; done               && \
    mysql -uroot -e "DROP USER IF EXISTS wp_user;"                                      && \
    mysql -uroot -e "CREATE USER 'wp_user' IDENTIFIED BY 'wp_password';"                && \
    mysql -uroot -e "DROP DATABASE IF EXISTS wp_database;"                              && \
    mysql -uroot -e "CREATE DATABASE wp_database;"                                      && \
    mysql -uroot -e "GRANT ALL ON wp_database.* TO 'wp_user';"                          && \
    mysql -uroot -e "FLUSH PRIVILEGES;"                                                 


## Install Wordpress - this times out sometimes. Just restart. Script is idempotent
RUN wget https://wordpress.org/latest.tar.gz    && \
tar xpf latest.tar.gz                           && \
rm -rf latest.tar.gz                            && \
rm -rf /var/www/html                            && \
cp -r wordpress /var/www/html                   


## Moved to here in Dockerfile so that MariaDB & WP would not have to keep being rebuilt
## Configure apache2: This script generates a cert for https
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

## Add supervisord to properly startup the 3 executables - ssh, apache2. mysqld
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./supervisord.conf /etc/supervisor/supervisord.conf
COPY ./supervisord.conf /etc/supervisord.conf

## Got to fix permissions on Wordpress /html directory & restart Apache2
RUN chown -R www-data:www-data /var/www/html        && \
find /var/www/html -type d -exec chmod 755 {} \;    && \
find /var/www/html -type f -exec chmod 644 {} \;    
 
## ENTRYPOINT ["docker-entrypoint.sh"]
EXPOSE 22 80 443 3306

CMD ["/bin/bash", "/start.sh"]






