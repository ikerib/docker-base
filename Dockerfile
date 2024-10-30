FROM php:8.3-apache

ARG UID=1463240267
ARG USER=appuser
ARG COMPOSER_VERSION=2.8.1
ARG REDIS_VERSION=5.3.7
ARG TZ="Europe/Madrid"

# Create user with the same UID as the host and some useful utilities
RUN adduser -u ${UID} --disabled-password --gecos "" ${USER} \
    && mkdir /home/${USER}/.ssh \
    && chown -R ${USER}:${USER} /home/${USER}/ \
    && echo "StrictHostKeyChecking no" >> /home/${USER}/.ssh/config \
    && echo "alias sf=/var/www/html/bin/console" >> /home/${USER}/.bashrc \
    && echo "alias l=ls -lah" >> /home/${USER}/.bashrc

# Timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN printf '[Date]\ndate.timezone="%s"\n', $TZ > /usr/local/etc/php/conf.d/tzone.ini

# Xdebug
RUN mkdir /var/log/xdebug && touch /var/log/xdebug/xdebug.log && chmod 777 /var/log/xdebug/xdebug.log

# Install packages and PHP extensions
RUN apt update \
    && apt install -y --no-install-recommends \
       git acl openssl openssh-client wget zip unzip \
       libpng-dev zlib1g-dev libzip-dev libxml2-dev libicu-dev \
       libldap-dev libldap2-dev \
       libxrender1 libxext6 libfontconfig1 libssl-dev \
       libxslt-dev \
    && docker-php-ext-install intl pdo gd zip \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install xml \
    && docker-php-ext-install xsl \
    && pecl install xdebug apcu redis-${REDIS_VERSION} \
    && docker-php-ext-enable --ini-name 05-opcache.ini opcache xdebug apcu redis xml xsl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --version=${COMPOSER_VERSION} \
    && mv composer.phar /usr/local/bin/composer

# PDF library needs
RUN mkdir -p /var/cache/fontconfig && \
    chown www-data:www-data /var/cache/fontconfig && \
    chmod 755 /var/cache/fontconfig && \
    mkdir -p /var/www/html/var/cache/dev/snappy && \
    chown -R www-data:www-data /var/www/html/var/cache/dev/snappy && \
    chmod -R 755 /var/www/html/var/cache/dev/snappy && \
    mkdir -p /var/www/html/public/uploads && \
    chown -R www-data:www-data /var/www/html/public/uploads

# Set correct permissions on the apache2 directories
RUN chown -R www-data:www-data /var/run/apache2 /var/lock/apache2

# Update Apache config
COPY ./docker/php/conf/default.conf /etc/apache2/sites-available/default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && a2enmod rewrite \
    && a2dissite 000-default \
    && a2ensite default

# Remove old PID and start Apache in the foreground
ENTRYPOINT ["sh", "-c", "rm -f /var/run/apache2/apache2.pid && apache2-foreground"]

# Switch to the dynamically created user
USER ${USER}

WORKDIR /var/www/html
