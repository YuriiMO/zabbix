# Берем за основу ubuntu
FROM ubuntu:18.04

# проверяем пакеты для обновления и обновляем если таковы есть
RUN apt-get -y update

# установка wget 
RUN apt-get -y install wget

# утилитой wget скачиваем пакет конфигурации репозитория
RUN wget https://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-3+bionic_all.deb

# установка пакета репозитория 
RUN dpkg -i zabbix-release_4.0-3+bionic_all.deb && rm zabbix-release_4.0-3+bionic_all.deb

# обновляем чтоб увидеть пакеты из нового репозитория
RUN apt-get -y update

# настройка тайм зоны
ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# установка забикс-сервера и фронтентд-пакета  
RUN apt-get -y install php-mysql zabbix-server-mysql zabbix-frontend-php

# очистка скачанных пакетов и кэша
RUN apt-get -y autoremove && apt-get -y clean

# при настройке базы данных возникла проблема, файл с шаблоном базы не появился в том вместе где должен был быть по мануалу 
# понять почему так происходит не хватило времени, решил проблему другим способом,   
# скачал исходники в которых есть файлы шаблона
RUN wget https://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/4.0.14/zabbix-4.0.14.tar.gz
RUN tar -zxvf zabbix-4.0.14.tar.gz && rm zabbix-4.0.14.tar.gz

# скриптом настраиваем базу из папки с исходниками
ADD data.sh /
RUN bash -c "/data.sh"

# удаляем уже не нужную папку с исходниками
RUN rm -r zabbix-4.0.14

# скачиваем tini для пресечения потребления памяти зомби-процессами
ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /sbin/tini
RUN chmod +x /sbin/tini

# поправляем конфиг файлы для работи забикс-сервера, фронтенда, апача
RUN sed -i 's!# php_value date.timezone Europe/Riga!php_value date.timezone Europe/Kiev!' /etc/apache2/conf-enabled/zabbix.conf
RUN sed -i 's!# DBHost=localhost!DBHost=localhost!'  /etc/zabbix/zabbix_server.conf
RUN sed -i 's!# DBPassword=!DBPassword=zabbix!'  /etc/zabbix/zabbix_server.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# создаем линк где лежит фронтенд в папку www/html/ 
RUN ln -s usr/share/zabbix /var/www/html/

# для запуска забикс-сервера нужно создать папку и назначить  ей владельца и группу "zabbix:zabbix"
RUN mkdir /var/run/zabbix
RUN chown zabbix:zabbix /var/run/zabbix

# открываем порты
EXPOSE 80
EXPOSE 10051

# указываем рабочуюю директорию
WORKDIR /var/lib/zabbix

# запуск скрипта в котором по очереди подымаются  сервисы mysql, appache, zabbix-server  
COPY ["run.sh", "/usr/bin/"]
ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/run.sh"]
