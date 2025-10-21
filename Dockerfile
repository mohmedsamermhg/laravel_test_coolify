FROM php:8.1-fpm-alpine

WORKDIR /var/www/html

# Install packages
RUN apk add --no-cache \
    nginx \
    supervisor \
    mysql-client \
    git \
    zip \
    unzip

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application
COPY . /var/www/html

# Setup Laravel environment and directories
RUN if [ ! -f .env ] && [ -f .env.example ]; then cp .env.example .env; fi \
    && mkdir -p storage/framework/views \
    && mkdir -p storage/framework/sessions \
    && mkdir -p storage/framework/cache/data \
    && mkdir -p storage/logs \
    && mkdir -p bootstrap/cache \
    && chmod -R 777 storage bootstrap/cache

# Run composer scripts after code is copied
RUN composer run-script post-autoload-dump || true

# Run Laravel optimizations
RUN composer install \
    php artisan config:clear || true \
 && php artisan route:clear || true \
 && php artisan view:clear || true \
 && php artisan config:cache || true \
 && php artisan route:cache || true \
 && php artisan view:cache || true \
 && php artisan storage:link --force || true

# Set ownership and permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Copy configs
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8000

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
