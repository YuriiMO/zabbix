#!/bin/bash
service mysql start

mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';"

mysql -uzabbix -p'zabbix' zabbix < /zabbix-4.0.14/database/mysql/schema.sql
mysql -uzabbix -p'zabbix' zabbix < /zabbix-4.0.14/database/mysql/images.sql
mysql -uzabbix -p'zabbix' zabbix < /zabbix-4.0.14/database/mysql/data.sql

service mysql stop
