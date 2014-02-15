ubuntu-13.10-sshd
=================

Dockerfile to be use to build image for docker container with ubuntu 13.10 plus sshd service

sshd base on angelrr7702/ubuntu-13.10

login : root password: rootprovisonal ==> replace password when using it

to create and execute the container :

sudo docker run -d -p 22 angelrr7702/ubuntu-13.10-sshd /usr/sbin/sshd -D
