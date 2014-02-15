# docker-drupal-dev
<br />

A Dockerfile to be used to build an image to create a container to start a webservice for local drupal development.

login : root password: ub ==> replace password when using it  
mysql : root password: mypwd ==> replace password when using it

to create and execute the container :

checkout your drupal development code in /path/to/drupal7  
create sites/default/files and sites/default/settings.php if they not exists and make them writable as needed 

To keep your database between container starts, create a directory sites/default/files/mysql
  

Now you are ready to start the webservice:  
```bash
cd /path/to/drupal7
docker run -d -v `pwd`sites/default/files/mysql:/var/lib/mysql -v `pwd`:/var/www fjmk/docker-drupal-dev
```
>>>>>>> real markdown in README.md

Find the IP of the docker container:  
```
docker inspect `docker ps -q -l` | grep IPAddress | awk '{print $2}' | tr -d '",/n'
```
<br />
*NOTE: The **first** time you start the container you have to wait ~25 seconds before starting the browser*  
Start your browser: http://&lt;container_ip&gt;/ or http://&lt;container_ip&gt;/install.php

<br />
### Software installed

* sshd
* ubuntu 13.10
* apache 2.4.6
* php 5.5.3
* mysql 5.5
* opcache is configured
* xdebug remote is configured
* drush master branch (works for drupal 8)
* composer

<br />
### Advanced use.

Login to the container:  
ssh root@<container ip>  --> password ub

Add your own ssh key to login without password:  
ssh-copy-id root@&lt;container_ip&gt;  
<br />
###Todo:  

Howto use PHPStorm, xdebug and profiler  
Create a drush command to start the container
