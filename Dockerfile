FROM php:8.3

ARG APP_ENV=local
ENV APP_ENV=${APP_ENV}

WORKDIR /app

# Install common system dependencies
RUN apt-get update && apt-get install -y \
    libbrotli-dev \
    libzip-dev \
    unzip \
    default-mysql-client \
    && if [ "$APP_ENV" = "local" ]; then \
       apt-get install -y nodejs npm; \
    fi \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions and Swoole
RUN docker-php-ext-install pcntl zip pdo pdo_mysql \
    && pecl install swoole && docker-php-ext-enable swoole

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy project files and install dependencies
COPY . .
RUN composer install --no-scripts --no-autoloader \
    && if [ "$APP_ENV" = "local" ]; then npm install; fi \
    && composer dump-autoload --optimize \
    && php artisan octane:install --server=swoole

# Set correct permissions
RUN chown -R www-data:www-data /app && chmod -R 755 /app/storage

USER www-data

EXPOSE 8000

CMD if [ "$APP_ENV" = "local" ]; then \
        php artisan octane:start --server=swoole --host=0.0.0.0 --port=8000 --watch; \
    else \
        php artisan octane:start --server=swoole --host=0.0.0.0 --port=8000; \
    fi
