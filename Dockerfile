FROM php:7.4.30-fpm
LABEL org.opencontainers.image.source https://github.com/didilesmana/php74-fpm-docker 

# Download installer php extentions | Thanks to https://github.com/mlocati
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions http bcmath bz2 calendar  \
    exif gd gettext gmp igbinary msgpack mysqli \
    pcntl pgsql redis shmop sockets sysvmsg \ 
    sysvsem sysvshm xsl zip pdo_mysql pdo_pgsql pdo_sqlsrv sqlsrv

# Config timezone server GMT+7 WIB
ENV CONTAINER_TIMEZONE="Asia/Jakarta"
RUN rm -f /etc/localtime \
&& ln -s /usr/share/zoneinfo/${CONTAINER_TIMEZONE} /etc/localtime

# Config limit file upload
RUN echo "post_max_size=20M" >> $PHP_INI_DIR/conf.d/memory-limit.ini
RUN echo "upload_max_filesize=20M" >> $PHP_INI_DIR/conf.d/memory-limit.ini

# Config timezone php GMT+7 WIB
RUN echo "date.timezone=Asia/Jakarta" > $PHP_INI_DIR/conf.d/date_timezone.ini

# Display errors in stderr
RUN echo "display_errors=stderr" > $PHP_INI_DIR/conf.d/display-errors.ini

# Disable PathInfo
RUN echo "cgi.fix_pathinfo=0" > $PHP_INI_DIR/conf.d/path-info.ini

# Disable expose PHP
RUN echo "expose_php=0" > $PHP_INI_DIR/conf.d/path-info.ini

# Config php-fpm www.conf
RUN sed -i "s|pm\s*=\s*dynamic|pm = static|g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s|pm.max_children\s*=\s*5|pm.max_children = 50|g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s|pm.start_servers\s*=\s*2|pm.start_servers = 20|g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s|pm.min_spare_servers\s*=\s*1|pm.min_spare_servers = 10|g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s|pm.max_spare_servers\s*=\s*3|pm.max_spare_servers = 30|g" /usr/local/etc/php-fpm.d/www.conf

EXPOSE 9000