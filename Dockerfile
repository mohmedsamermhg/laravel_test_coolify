FROM serversideup/php:8.1-fpm-nginx

ENV PHP_OPCACHE_ENABLE=1

USER root

# Install Node.js if needed
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# Copy application files
COPY --chown=www-data:www-data . /var/www/html

USER www-data

# Install dependencies
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Build assets (if needed)
RUN npm install
RUN npm run build

# Back to root for final setup
USER root
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 8080

USER www-data
