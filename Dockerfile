# ubuntu-14.10
# VERSION               0.1.0
FROM ubuntu:14.04
MAINTAINER Frans Kuipers  "franskuipers@gmail.com"

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
RUN apt-get install -y -q nano supervisor php5 libapache2-mod-php5 php5-gd apache2 php5-json cron php5-curl php5-xdebug mysql-client php5-mysql git curl

ADD start.sh /start.sh
ADD foreground.sh /etc/apache2/foreground.sh
ADD opcache.ini /etc/php5/mods-available/opcache.ini
ADD xdebug.ini /etc/php5/mods-available/xdebug.ini
ADD apache2.conf /etc/apache2/apache2.conf
ADD php.ini /etc/php5/apache2/php.ini

RUN (git clone https://github.com/drush-ops/drush.git /usr/local/drush && ln -s /usr/local/drush/drush /usr/local/bin/drush)

## TODO REMOVE
RUN (curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && composer config -g github-oauth.github.com a772a8fb523b791d57713483faff328f61f06bec)

RUN (curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && cd /usr/local/drush && composer install)

# install some handy d8 scripts
ADD d8-cleanup /usr/local/bin/d8-cleanup 
ADD d8-reinstall /usr/local/bin/d8-reinstall 
ADD d8-upgrade /usr/local/bin/d8-upgrade 
RUN (chmod 750 /usr/local/bin/d8-*)

RUN (mkdir /root/.ssh)
ADD authorized_keys /root/.ssh/authorized_keys 
RUN (chmod 750 /root/.ssh && chmod 600 /root/.ssh/authorized_keys && chown root:root /root/.ssh/authorized_keys)

RUN (chmod 750 /start.sh && chmod 750 /etc/apache2/foreground.sh )
RUN (a2enmod rewrite)

RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22 80 9000
CMD ["/bin/bash", "-e", "/start.sh"]
