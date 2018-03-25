FROM debian:stretch-slim
LABEL maintainer="tom@frogtownroad.com"

## ENV user=dockter-tom
## RUN groupadd -r ${user} && useradd -r -l -M ${user} -g ${user} 

WORKDIR .
## Update packages
RUN apt-get update  -y

## Install Apache
RUN apt-get install apache2 libapache2-mod-php7.0 wget  -y

## Install PHP
RUN apt-get install php7.0 php7.0-mysql  -y

## Install wget - moved to PHP

## Install Mysql non-interactively
RUN export DEBIAN_FRONTEND="noninteractive"                                                                  && \
echo mariadb-server-10.0 mariadb-server/root_password password tmpsetup | debconf-set-selections             && \
echo mariadb-server-10.0 mariadb-server/root_password_again password tmpsetup | debconf-set-selections       && \
apt-get install mariadb-client mariadb-server -y

RUN service mysql restart 
## ARG mysql_pid=$!
RUN mysqld_safe & until mysqladmin ping >/dev/null 2>&1; do sleep 1; done               && \
    mysql -uroot -e "DROP USER IF EXISTS wp_user;"                                      && \
    mysql -uroot -e "CREATE USER 'wp_user' IDENTIFIED BY 'wp_password';"                && \
    mysql -uroot -e "DROP DATABASE IF EXISTS wp_database;"                              && \
    mysql -uroot -e "CREATE DATABASE wp_database;"                                      && \
    mysql -uroot -e "GRANT ALL ON wp_database.* TO 'wp_user';"                          && \
    mysql -uroot -e "FLUSH PRIVILEGES;"                                                 

##    mysqladmin shutdown                                                                
##    wait $mysql_pid                                                                    
##    service mysql restart


## Install Wordpress - this times out sometimes. Just restart. Script is idempotent
                  
RUN wget https://wordpress.org/latest.tar.gz    && \
tar xpf latest.tar.gz                           && \
rm -rf latest.tar.gz                            && \
rm -rf /var/www/html                            && \
cp -r wordpress /var/www/html                   
## rm -rf ./wordpress

## Got to fix permissions on Wordpress /html directory & restart Apache2
RUN chown -R www-data:www-data /var/www/html        && \
find /var/www/html -type d -exec chmod 755 {} \;    && \
find /var/www/html -type f -exec chmod 644 {} \;    

RUN service apache2 restart
RUN service mysql restart

EXPOSE 80 443 3306
CMD ["/bin/bash"]
