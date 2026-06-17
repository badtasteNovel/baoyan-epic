# syntax=docker/dockerfile:1
# image-name: my-php-base:8.4
FROM php:8.4-fpm-bookworm
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN install-php-extensions \
    pdo_pgsql \
    pgsql \
    gd \
    zip \
    intl \
    bcmath \
    opcache \
    sockets \
    redis \
    grpc \
    pcntl

