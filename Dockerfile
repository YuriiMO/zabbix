FROM ubuntu:18.04
RUN wget https://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-2+bionic_all.deb
RUN dpkg -i zabbix-release_4.0-2+bionic_all.deb
RUN apt update
RUN apt install zabbix-server-mysql
RUN apt install zabbix-proxy-mysql
RUN apt install zabbix-frontend-php
