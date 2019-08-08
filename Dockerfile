FROM php:7.2-apache

ENV DEBIAN_FRONTEND noninteractive

RUN a2enmod rewrite

RUN apt-get update && apt-get -y install git mysql-client vim-tiny wget httpie unzip iputils-ping xvfb

# Suppressing menu to choose keyboard layout
# COPY ./keyboard /etc/default/keyboard

# Install the PHP extensions we need
RUN apt-get install -y libpng-dev libjpeg-dev libpq-dev zlib1g-dev \
	&& apt-get install -y openssl build-essential xorg libssl-dev wkhtmltopdf \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mbstring pdo pdo_mysql pdo_pgsql zip

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install Drush 8.
RUN composer global require drush/drush:8.*
RUN composer global update
RUN ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush

# Add drush comand https://www.drupal.org/project/registry_rebuild
RUN wget http://ftp.drupal.org/files/projects/registry_rebuild-7.x-2.5.tar.gz && \
    tar xzf registry_rebuild-7.x-2.5.tar.gz && \
    rm registry_rebuild-7.x-2.5.tar.gz && \
    mv registry_rebuild /root/.composer/vendor/drush/drush/commands

# PHP.ini settings for Opigno to work
RUN echo "memory_limit=512M" >> /usr/local/etc/php/conf.d/memory-limit.ini \
	&& echo "max_execution_time=120" >> /usr/local/etc/php/conf.d/max-execution-time.ini \
  && echo "xdebug.max_nesting_level=200" >> /usr/local/etc/php/conf.d/xdebug_max_nesting_level.ini \
  && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20170718/opcache.so" >> /usr/local/etc/php/conf.d/opcache.ini \
  && echo "upload_max_filesize=10M" >> /usr/local/etc/php/conf.d/upload_max_filesize.ini \
  && echo "post_max_size=10M" >> /usr/local/etc/php/conf.d/post_max_size.ini

# Clear composer and apt cache
RUN composer clear-cache
RUN apt-get clean

# TODO Execute Composer Install

# PHP library external
# RUN docker-php-ext-install bcmath
