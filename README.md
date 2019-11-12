zabbix-server

Данная сборка может работать пока работает сам контейнер              
Для коректной работы директории:        
/var/lib/mysql  #базы данных mysql      
/var/lib/zabbix #рабочий каталог zabbix         
/usr/lib/zabbix #пользовательские скрипты          
нужно вынести в файловую систему хост машины

Для запуска:
docker pull selest1n/zabbix:0.1.2
docker run -d -p 80:80 -p 10051:10051 selest1n/zabix:0.1.2

http://0.0.0.0/zabbix

первоначальная конфигурация доступа к базе        
mysql user : zabbix         
mysql password: zabbix

Вход на веб панель          
login: Admin          
password: zabbix
