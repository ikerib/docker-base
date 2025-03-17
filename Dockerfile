ARG PHP_VERSION=8.3-apache
FROM php:${PHP_VERSION}

ARG UID=1463240267
ARG USER=appuser
ARG COMPOSER_VERSION=2.8.5
ARG TZ="Europe/Madrid"

# Uid berdineko erabiltzailea sortu eta hainbat alias
RUN adduser -u ${UID} --disabled-password --gecos "" ${USER} \
    && usermod -aG www-data ${USER} \
    && mkdir -p /home/${USER}/.ssh \
    && chown -R ${USER}:${USER} /home/${USER} \
    && echo "StrictHostKeyChecking no" >> /home/${USER}/.ssh/config \
    && echo 'alias sf="/var/www/html/bin/console"' >> /home/${USER}/.bashrc \
    && echo 'alias l="ls -lah"' >> /home/${USER}/.bashrc

# Zona ordutegia konfirguratu
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone \
    && printf '[Date]\ndate.timezone="%s"\n' ${TZ} > /usr/local/etc/php/conf.d/tzone.ini

# log eta xdebug karpetak sortu beharrezko baimenekin
RUN mkdir -p /var/log/xdebug && touch /var/log/xdebug/xdebug.log && chmod 777 /var/log/xdebug/xdebug.log

# PHP pakete eta liburutegiak instalatu
RUN apt update \
    && apt install -y --no-install-recommends \
       git acl openssl openssh-client wget zip unzip \
       libpng-dev zlib1g-dev libzip-dev libxml2-dev libicu-dev \
       libldap2-dev libxrender1 libxext6 libfontconfig1 libssl-dev \
       libxslt-dev libicu-dev supervisor \
    && docker-php-ext-install intl pdo gd zip pdo_mysql xml xsl \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap \
    && pecl install xdebug apcu \
    && docker-php-ext-enable opcache xdebug apcu \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# Redis instalatu
RUN pecl install redis-5.3.7 \
    && docker-php-ext-enable redis \
    &&  rm -rf /tmp/pear

# Chomium eta driver instalatu
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-driver    

# Karpeta estruktura sortu eta baimenak balioztatu
RUN mkdir -p /var/www/html /var/cache/fontconfig /var/www/html/var/cache/dev/snappy /var/www/html/public/uploads \
    && chown -R www-data:www-data /var/cache/fontconfig /var/www/html/var/cache/dev/snappy \
    && chown -R www-data:www-data /var/www/html/public/uploads \
    && chmod -R 775 /var/www/html/public/uploads \
    && chmod g+s /var/www/html/public/uploads

# Composer instalatu
RUN curl -sS https://getcomposer.org/installer | php -- --version=${COMPOSER_VERSION} \
    && mv composer.phar /usr/local/bin/composer

# Konfigurazioak
COPY ./docker/php/conf/xdebug.ini  /usr/local/etc/php/conf.d/xdebug.ini
COPY ./docker/php/conf/php.ini  /usr/local/etc/php/conf.d/php.ini

COPY ./docker/php/conf/default.conf /etc/apache2/sites-available/default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && a2enmod rewrite \
    && a2dissite 000-default \
    && a2ensite default

# PID zaharra ezabatu eta apache abiarazi
ENTRYPOINT ["sh", "-c", "rm -f /var/run/apache2/apache2.pid && apache2-foreground"]

# sortutako erabiltzailea aukeratu
USER ${USER}

WORKDIR /var/www/html