# Start from the official Moodle PHP-Apache image
FROM moodlehq/moodle-php-apache:8.3

# Install git and unzip, required for cloning the repository and running Composer
RUN apt-get update && apt-get install -y git unzip && rm -rf /var/lib/apt/lists/*

# Clear the default html folder and clone the Moodle core repository (5.2 Stable branch)
RUN rm -rf /var/www/html \
    && git clone --depth=1 -b MOODLE_502_STABLE git://git.moodle.org/moodle.git /var/www/html

# Copy the custom configuration file
COPY config.php /var/www/html/config.php

# Copy custom initialization scripts to the entrypoint directory
COPY entrypoint-scripts/ /docker-entrypoint.d/

# Install Composer and PHP dependencies
WORKDIR /var/www/html
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --no-dev --classmap-authoritative

# Set appropriate ownership and permissions for the Apache web server (www-data)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod +x /docker-entrypoint.d/*.sh
