# syntax=docker/dockerfile:1
# # image-name: my-dev-php-fpm:debian-bookworm
FROM my-php-release:debian-bookworm
WORKDIR /var/www/html
USER root
RUN apt-get update && apt-get install -y --no-install-recommends procps && rm -rf /var/lib/apt/lists/*
USER www-data
