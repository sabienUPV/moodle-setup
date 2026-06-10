# Start from the official Moodle PHP-Apache image
FROM moodlehq/moodle-php-apache:8.3

# Install git and unzip, required for cloning the repository and running Composer
RUN apt-get update && apt-get install -y git unzip && rm -rf /var/lib/apt/lists/*

# Because the default workdir is /var/www/html,
# and we need to delete it to be able to replace it with the moodle code,
# we temporarily move back one directory so we can delete it and git clone it without it breaking
WORKDIR /var/www

# Clear the default html folder and clone the Moodle core repository (5.2 Stable branch)
RUN rm -rf /var/www/html \
    && git clone --depth=1 -b MOODLE_502_STABLE https://github.com/moodle/moodle.git /var/www/html

# Copy the custom configuration file
COPY config.php /var/www/html/config.php

# Copy custom initialization scripts to the entrypoint directory
COPY entrypoint-scripts/ /docker-entrypoint.d/

# We change the workdir back to the new /var/www/html folder
# (needed to be able to install composer and PHP dependencies)
WORKDIR /var/www/html

# Install Composer and PHP dependencies
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --no-dev --classmap-authoritative

# Set appropriate ownership and permissions for the Apache web server (www-data)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod +x /docker-entrypoint.d/*.sh
