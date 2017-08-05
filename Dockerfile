FROM ubuntu:14.04
RUN apt-get update && apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
  apache2 libapache2-mod-php5 php5-mysql php5-gd php5-mcrypt php-pear php-apc php5-curl curl lynx-cur

RUN \
 sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini && \
 sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini && \
 sed -i "s/display_errors = Off/display_errors = On/" /etc/php5/apache2/php.ini && \
 sed -i "s/AllowOverride None/AllowOverride All/" /etc/apache2/apache2.conf && \
 sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=0/" /etc/php5/apache2/php.ini && \
 sed -i "s/;mbstring.func_overload.*$/mbstring.func_overload=2/" /etc/php5/apache2/php.ini && \
 sed -i "s/;date.timezone.*$/date.timezone = Asia\/Yakutsk/" /etc/php5/apache2/php.ini && \
 sed -i "s/;mbstring.internal_encoding.*$/mbstring.internal_encoding=UTF-8/" /etc/php5/apache2/php.ini && \
 sed -i "s/;realpath_cache_size.*$/realpath_cache_size=8M/" /etc/php5/apache2/php.ini && \
 sed -i "s/; max_input_vars = 1000/max_input_vars = 10000/" /etc/php5/apache2/php.ini && \
 sed -i "s/;pcre.recursion_limit=100000/pcre.recursion_limit=100000/" /etc/php5/apache2/php.ini && \
 sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 40M/" /etc/php5/apache2/php.ini && \
 sed -i "s/post_max_size = 8M/post_max_size = 40M/" /etc/php5/apache2/php.ini && \
 sed -i "s/memory_limit = 128M/memory_limit = 256M/" /etc/php5/apache2/php.ini


ENV APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid 

COPY ./scripts/* /root/scripts/
COPY ./conf/conf-available/* /etc/apache2/conf-available/
COPY ./conf/mods-available/* /etc/apache2/mods-available/
RUN chmod +x /root/scripts/* && rm -f /var/www/html/index.html

RUN a2enmod remoteip && a2enconf remoteip && a2enmod php5 && a2enmod rewrite && php5enmod mcrypt

ADD http://www.1c-bitrix.ru/download/scripts/bitrixsetup.php /var/www/html
ADD http://www.1c-bitrix.ru/download/scripts/restore.php /var/www/html/
RUN chown -R www-data:www-data /var/www/html && chown -R www-data:www-data /var/lib/php5

EXPOSE 80
CMD ["/root/scripts/boot.sh"]