FROM php:latest

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y libicu-dev && docker-php-ext-install intl pdo pdo_mysql

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY . /var/www/html

RUN chown -R www-data:www-data /var/www/html

CMD ["php", "-S", "0.0.0.0:80", "-t", "/var/www/html"]
