# syntax=docker/dockerfile:1
# 多此運行階段是必須把 composer 和 node js 進行切割，不能將他們放入image裡面增加體積。
# composer 與 node.js 的環境存在於my-php-builder:8.4映像檔案中

# image-name: my-php-release:debian-bookworm
FROM my-php-builder:8.4

USER root
WORKDIR /var/www/html
COPY docker/web/app/php-fpm/production-php.ini /usr/local/etc/php/conf.d/custom-php.ini

# 從 builder 把編譯好的東西搬過來

COPY .env.example .env
RUN mkdir -p storage/app/qztray-public storage/app/qztray-private && \
    chown -R www-data:www-data storage bootstrap/cache && \
    find storage bootstrap/cache -type d -exec chmod 775 {} + && \
    find storage bootstrap/cache -type f -exec chmod 664 {} + 
USER www-data
RUN php artisan config:clear
RUN php artisan package:discover --ansi
RUN rm .env