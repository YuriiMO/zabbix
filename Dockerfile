FROM ubuntu:18.04

RUN apt-get -y update
RUN apt-get -y install wget
RUN wget https://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-3+bionic_all.deb
RUN dpkg -i zabbix-release_4.0-3+bionic_all.deb && rm zabbix-release_4.0-3+bionic_all.deb
RUN apt-get -y update

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -y install php-mysql zabbix-server-mysql zabbix-frontend-php
RUN apt-get -y autoremove && apt-get -y clean

RUN wget https://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/4.0.14/zabbix-4.0.14.tar.gz
RUN tar -zxvf zabbix-4.0.14.tar.gz && rm zabbix-4.0.14.tar.gz

ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /sbin/tini
RUN chmod +x /sbin/tini

RUN sed -i 's!# php_value date.timezone Europe/Riga!php_value date.timezone Europe/Kiev!' /etc/apache2/conf-enabled/zabbix.conf

RUN sed -i 's!# DBHost=localhost!DBHost=localhost!'  /etc/zabbix/zabbix_server.conf
RUN sed -i 's!# DBPassword=!DBPassword=zabbix!'  /etc/zabbix/zabbix_server.conf

ADD data.sh /
RUN bash -c "/data.sh"
RUN rm -r zabbix-4.0.14

RUN mkdir /var/www/html/zabbix
RUN ln -s usr/share/zabbix /var/www/html/

RUN mkdir /var/run/zabbix
RUN chown zabbix:zabbix /var/run/zabbix

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

EXPOSE 80

WORKDIR /var/lib/zabbix

COPY ["run.sh", "/usr/bin/"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/run.sh"]
