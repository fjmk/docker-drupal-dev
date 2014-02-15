# ubuntu-13.10
# VERSION               0.0.5
FROM stackbrew/ubuntu:13.10
MAINTAINER Frans Kuipers  "franskuipers@gmail.com"

# ENV DEBIAN_FRONTEND noninteractive
RUN (locale-gen en_US en_US.UTF-8 nl_NL nl_NL.UTF-8 && dpkg-reconfigure locales)
RUN (apt-get update && apt-get upgrade -y -q && apt-get dist-upgrade -y -q && apt-get -y -q autoclean && apt-get -y -q autoremove)
RUN (apt-get install -y -q nano && echo 'root:ub' |chpasswd )
RUN (apt-get install -y -q openssh-server && mkdir -p /var/run/sshd)
#RUN (sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config)

# needed by ubuntu 13.10 to run sshd with keys
RUN (echo LANG=”en_US.UTF-8” > /etc/default/locale)
RUN (sed -i 's/session    required     pam_loginuid.so/session    optional     pam_loginuid.so/' /etc/pam.d/sshd)

RUN echo "deb http://archive.ubuntu.com/ubuntu saucy-backports main restricted " >> /etc/apt/sources.list

RUN (apt-get update && apt-get upgrade -y -q && apt-get dist-upgrade -y -q && apt-get -y -q autoclean && apt-get -y -q autoremove)
RUN (echo 'mysql-server-5.5 mysql-server/root_password password mypwd' | debconf-set-selections)
RUN (echo 'mysql-server-5.5 mysql-server/root_password_again password mypwd' |debconf-set-selections)
RUN apt-get install -y -q supervisor php5 libapache2-mod-php5 php5-gd apache2 php5-json cron php5-curl php5-xdebug mysql-server php5-mysql

ADD start.sh /start.sh
ADD foreground.sh /etc/apache2/foreground.sh
ADD first-run.sh /first-run.sh
ADD apache2.conf /etc/apache2/apache2.conf
RUN echo "apc.rfc1867 = 1" >> /etc/php5/apache2/php.ini

RUN (mkdir /root/.ssh)
ADD authorized_keys /root/.ssh/authorized_keys 
RUN (chmod 750 /root/.ssh && chmod 600 /root/.ssh/authorized_keys)

RUN (chmod 750 /start.sh && chmod 750 /etc/apache2/foreground.sh && chmod 750 /first-run.sh)
RUN (a2enmod rewrite)

RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22 80 9000
CMD ["/bin/bash", "-e", "/start.sh"]
