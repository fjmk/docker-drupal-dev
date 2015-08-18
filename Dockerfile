# ubuntu-14.10
# VERSION               0.1.0
FROM ubuntu:14.04
MAINTAINER Frans Kuipers  "franskuipers@gmail.com"

ENV DRUSH_VERSION 7.x
ENV DEBIAN_FRONTEND noninteractive

# enable ssh login
RUN apt-get update \
    && apt-get install -y openssh-server \
    && mkdir /var/run/sshd \
    && echo 'root:root' |chpasswd \
    && sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted " >> /etc/apt/sources.list

RUN (apt-get update && apt-get upgrade -y -q && apt-get dist-upgrade -y -q && apt-get -y -q autoclean && apt-get -y -q autoremove)
RUN apt-get install -y -q nano supervisor php5 libapache2-mod-php5 php5-gd apache2 php5-json cron php5-curl php5-xdebug mysql-client php5-mysql git curl unzip gzip

ADD start.sh /start.sh
ADD foreground.sh /etc/apache2/foreground.sh
ADD opcache.ini /etc/php5/mods-available/opcache.ini
ADD xdebug.ini /etc/php5/mods-available/xdebug.ini
ADD apache2-mpm-prod.conf /etc/apache2/mods-available/mpm_prefork.conf
ADD php-drupal-dev.ini /etc/php5/mods-available/drupal.ini
RUN php5enmod drupal
ADD apache-default.conf /etc/apache2/sites-available/000-default.conf
RUN mkdir /var/www/build
ADD index.php /var/www/build/index.php

# ADD some production config files
RUN mkdir /root/conf
ADD php-drupal-prod.ini /root/conf/php-drupal-prod.ini
ADD apache2-mpm-prod.conf /root/conf/apache2-mpm-prod.conf


RUN (git clone --branch $DRUSH_VERSION https://github.com/drush-ops/drush.git /usr/local/drush && ln -s /usr/local/drush/drush /usr/local/bin/drush)

## TODO REMOVE
RUN (curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && composer config -g github-oauth.github.com a772a8fb523b791d57713483faff328f61f06bec)

## install drush and kraftwagen
RUN (curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && cd /usr/local/drush && composer install)
RUN (mkdir -p /root/.drush && cd /root/.drush && git clone "https://github.com/kraftwagen/kraftwagen.git" && drush cc drush)


RUN (mkdir /root/.ssh)
ADD authorized_keys /root/.ssh/authorized_keys 
RUN (chmod 750 /root/.ssh && chmod 600 /root/.ssh/authorized_keys && chown root:root /root/.ssh/authorized_keys)

RUN (chmod 750 /start.sh && chmod 750 /etc/apache2/foreground.sh )
RUN (a2enmod rewrite)

RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# make ENVIRONMENT production in docker-compose.yml if needed 
ENV ENVIRONMENT development
ENV DOCROOT build

EXPOSE 22 80 9000
CMD ["/bin/bash", "-e", "/start.sh"]
