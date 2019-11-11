#!/bin/bash

# запускаем службу mysql
service mysql start

# Создаем базу zabbix с нужной кодировкой  
mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin;"

# создаем пользователя zabbix и даем ему полные права на базу zabbix
mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';"

# заливаем шаблон базы в новую базу данных zabbix
mysql -uzabbix -p'zabbix' zabbix < /zabbix-4.0.14/database/mysql/schema.sql
mysql -uzabbix -p'zabbix' zabbix < /zabbix-4.0.14/database/mysql/images.sql
mysql -uzabbix -p'zabbix' zabbix < /zabbix-4.0.14/database/mysql/data.sql

# службу mysql можно остановить
service mysql stop
