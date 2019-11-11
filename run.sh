#!/bin/bash

# для запуска процесса mysqld нужно создать папку и назначить  ей владельца и группу "mysql:mysql"
mkdir -p /var/run/mysqld
ln -s /var/run/mysqld /run/mysqld
chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /run/mysqld

# запуск mysqld с нужными ключами
echo " Starting MySQL server in background mode"
nohup /usr/sbin/mysqld --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib/mysql/plugin \
            --user=mysql --log-output=none --pid-file=/var/lib/mysql/mysqld.pid \
            --port=3306 --character-set-server=utf8 --collation-server=utf8_bin &

# запуск веб сервера apache 
echo " Starting Zabbix frontend" 
/bin/bash -c "source /etc/apache2/envvars"
nohup /usr/sbin/apache2ctl -D FOREGROUND &

# для запуска забикс-сервера нужно создать папку и назначить  ей владельца и группу "zabbix:zabbix"
mkdir /var/run/zabbix
chown zabbix:zabbix /var/run/zabbix

# запуск Zabbix server
echo " Starting Zabbix server"
exec su zabbix -s /bin/bash -c "/usr/sbin/zabbix_server --foreground -c /etc/zabbix/zabbix_server.conf"
