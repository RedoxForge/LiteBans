# Use the specified base image from docker-bake.hcl
ARG PHP_VERSION
FROM php:${PHP_VERSION}

# Set the working directory
WORKDIR /var/www/html

# Install necessary system packages and PHP extensions using args
ARG LIBICU_DEV_VERSION
ARG INTL_VERSION
ARG PDO_MYSQL_VERSION

RUN apt-get update && apt-get install -y libicu-dev=${LIBICU_DEV_VERSION} \
    && docker-php-ext-install intl pdo pdo_mysql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy the application code to the container
COPY . /var/www/html

# Set appropriate permissions
RUN chown -R www-data:www-data /var/www/html

# Switch to non-privileged user www-data
USER www-data

# Define the command to run the application
CMD ["php", "-S", "0.0.0.0:80", "-t", "/var/www/html"]

