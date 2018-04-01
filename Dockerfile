FROM debian:stretch-slim
LABEL maintainer="tom@frogtownroad.com"

## ENV user=dockter-tom
## RUN groupadd -r ${user} && useradd -r -l -M ${user} -g ${user} 

## Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

## Update packages
RUN apt-get update  -y

## Install utility packages --no-install-recommends
RUN apt-get install wget apt-utils supervisor openssh-server ca-certificates build-essential \
## Install Apache
apache2 libapache2-mod-php7.0 \
## Install PHP
php7.0 php7.0-mysql \
## Install Mariabd
mariadb-client mariadb-server --no-install-recommends -y && rm -rf /var/lib/apt/lists/* 

## Install Mysql non-interactively
RUN export DEBIAN_FRONTEND="noninteractive"                                                                  && \
echo mariadb-server-10.0 mariadb-server/root_password password tmpsetup | debconf-set-selections             && \
echo mariadb-server-10.0 mariadb-server/root_password_again password tmpsetup | debconf-set-selections      

RUN mysqld_safe & until mysqladmin ping >/dev/null 2>&1; do sleep 1; done               && \
    mysql -uroot -e "DROP USER IF EXISTS wp_user;"                                      && \
    mysql -uroot -e "CREATE USER 'wp_user' IDENTIFIED BY 'wp_password';"                && \
    mysql -uroot -e "DROP DATABASE IF EXISTS wp_database;"                              && \
    mysql -uroot -e "CREATE DATABASE wp_database;"                                      && \
    mysql -uroot -e "GRANT ALL ON wp_database.* TO 'wp_user';"                          && \
## Let's set up a remote root user with no password ##
##  mysql -uroot -e "use mysql;"					       		
##  mysql -uroot -e "UPDATE user SET password=null WHERE User='root';"        		&& \
##  mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '';"       && \
    mysql -uroot -e "FLUSH PRIVILEGES;"                                                 


## Install Wordpress - this times out sometimes. Just restart. Script is idempotent
RUN wget https://wordpress.org/latest.tar.gz    && \
tar xpf latest.tar.gz                           && \
rm -rf latest.tar.gz                            && \
rm -rf /var/www/html                            && \
cp -r wordpress /var/www/html                   


## Moved to here in Dockerfile so that MariaDB & WP would not have to keep being rebuilt
## Configure apache2: This script generates a cert for https
COPY ./start.sh /opt/start.sh
RUN chmod 755 /opt/start.sh 
RUN bash /opt/start.sh

## Add supervisord.conf to startup the 3 executables - ssh, apache2. mysqld
## COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
## COPY ./supervisord.conf /etc/supervisor/supervisord.conf
COPY ./supervisord.conf /etc/supervisord.conf

## Open permissions on Wordpress /html directory & let supervisord restart Apache2
RUN chown -R www-data:www-data /var/www/html        && \
find /var/www/html -type d -exec chmod 777 {} \;    && \
find /var/www/html -type f -exec chmod 777 {} \;    
 
EXPOSE 22:22 80:80 443:443 3306:3306

CMD ["/usr/bin/supervisord","--configuration=/etc/supervisord.conf"]