FROM debian:stretch-slim
LABEL maintainer="tom@frogtownroad.com"

ENV user=dockter-tom
RUN groupadd -r ${user} && useradd -r -l -M ${user} -g ${user} 

WORKDIR .
COPY build-lamp.sh .
RUN chmod +x build-lamp.sh
RUN /bin/bash ./build-lamp.sh

RUN service mysql start

RUN mysql -u root  <<EOF \
DROP USER IF EXISTS wp_user; \
CREATE USER 'wp_user' IDENTIFIED BY 'wp_password'; \
DROP DATABASE IF EXISTS wp_database; \
CREATE DATABASE wp_database; \
GRANT ALL ON wp_database.* TO 'wp_user'; \
FLUSH PRIVILEGES; \
EOF

## Install Wordpress - this times out sometimes. Just restart. Script is idempotent
RUN apt-get install wget -y                     && \
wget https://wordpress.org/latest.tar.gz        && \
tar xpf latest.tar.gz                           && \
rm -rf latest.tar.gz                            && \
rm -rf /var/www/html                            && \
cp -r wordpress /var/www/html                   && \
rm -rf wordpress

## Got to fix permissions on Wordpress /html directory
RUN chown -R www-data:www-data /var/www/html        && \
find /var/www/html -type d -exec chmod 755 {} \;    && \
find /var/www/html -type f -exec chmod 644 {} \;    && \
service apache2 restart

EXPOSE 80 443 3306
CMD ["/bin/bash"]
