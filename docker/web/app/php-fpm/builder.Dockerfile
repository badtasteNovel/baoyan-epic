# syntax=docker/dockerfile:1
# image-name: my-php-builder:8.4
# --- 1. 基礎環境 ---
FROM my-php-base:8.4 AS base
COPY --from=node:20-slim /usr/local /usr/local
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /app

# --- 2. Wayfinder 階段 (只專心生 JS) ---
FROM base AS wayfinder_stage
COPY . .
RUN composer install --no-interaction --optimize-autoloader --no-scripts
RUN --mount=type=secret,id=build_env \
    cp /run/secrets/build_env .env
RUN php artisan package:discover --ansi
RUN php artisan wayfinder:generate --with-form

# --- 3. NPM 階段 (編譯前端) ---
FROM base AS npm_stage
# 為什麼這裡還要再進行一次 COPY 呢 因為必須要偵測js 到底有沒有改動。
# 如果直接拿取wayfinder_stage 的東西，那麼js 的打包就完全依靠Wayfinder 的改動。完全不會改到js
# 這裡必須要用wayfinder_stage 的打包資料，是因為假設前端有寫到wayfinder那就必須打包進去。 否則run build 會失敗。
COPY package.json package-lock.json ./
RUN npm install
COPY . .
COPY --from=wayfinder_stage /app/resources/js /app/resources/js
RUN npm run build

# --- 4. 最終組合 (Main) ---
FROM base AS main
WORKDIR /var/www/html
COPY --from=wayfinder_stage /app .
COPY --from=wayfinder_stage /app/resources/js/actions ./resources/js/actions
COPY --from=wayfinder_stage /app/resources/js/routes ./resources/js/routes
COPY --from=wayfinder_stage /app/resources/js/wayfinder ./resources/js/wayfinder
COPY --from=npm_stage /app/public/build ./public/build

# 權限與最後校正
RUN rm .env
USER www-data
