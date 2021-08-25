FROM php:7.3.25-apache AS build

# install the PHP extensions we need

# GD extension
RUN apt-get update && apt-get install -y \
	libpng-dev libjpeg-dev apt-utils libfreetype6-dev libmcrypt-dev libjpeg-dev apt-utils \
	&& rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/freetype2 \
        --with-png-dir=/usr/include \
        --with-jpeg-dir=/usr/include \
    && docker-php-ext-install gd 
	
# SOAP extension	
RUN apt-get update -y \
	&& apt-get install -y \
    libxml2-dev \
	&& apt-get clean -y \
	&& docker-php-ext-install soap
 
# MCRYPT extension
RUN pecl install mcrypt && docker-php-ext-enable mcrypt

# Redis extension
ENV EXT_REDIS_VERSION=4.3.0 EXT_IGBINARY_VERSION=3.0.1

RUN docker-php-source extract \
    # igbinary
    && mkdir -p /usr/src/php/ext/igbinary \
    &&  curl -fsSL https://github.com/igbinary/igbinary/archive/$EXT_IGBINARY_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/igbinary --strip 1 \
    && docker-php-ext-install igbinary \
    # redis
    && mkdir -p /usr/src/php/ext/redis \
    && curl -fsSL https://github.com/phpredis/phpredis/archive/$EXT_REDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && docker-php-ext-configure redis --enable-redis-igbinary \
    && docker-php-ext-install redis \
    # cleanup
    && docker-php-source delete

# Enable PDO
RUN docker-php-ext-install mysqli pdo pdo_mysql
	
# Enable Apache re-write mode
RUN cp /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/ && \
    cp /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/

#RUN a2enmod rewrite

ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_PID_FILE  /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_LOG_DIR   /var/log/apache2

RUN mkdir -p $APACHE_RUN_DIR
RUN mkdir -p $APACHE_LOCK_DIR
RUN mkdir -p $APACHE_LOG_DIR

#Enable SSL/TLS apache configs
RUN apt-get update && \
    apt-get install -y \
        zlib1g-dev
COPY apache-ssl/ssl.crt/server.crt /etc/apache2/ssl/server.crt
COPY apache-ssl/ssl.key/server.key /etc/apache2/ssl/server.key
COPY apache-ssl/ssl.conf /etc/apache2/sites-enabled/ssl.conf
RUN a2enmod ssl
RUN service apache2 restart
COPY apache-ssl/http.conf /etc/apache2/sites-enabled/000-default.conf

# Set default work directory  
WORKDIR /var/www/html
COPY --chown=www-data:www-data . .

CMD ["/usr/sbin/apache2", "-D",  "FOREGROUND"]