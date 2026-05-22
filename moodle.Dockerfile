FROM moodlehq/moodle-php-apache:8.3 as moodle

# Inject the Apache Router configuration directly into the image
COPY ./apache-config/moodle-router.conf /etc/apache2/conf-enabled/moodle-router.conf

FROM moodle as moodle-prod

# Apply PHP security configuration natively to avoid warnings about sharing sensitive info in error logs
# (this should only be used in production (or staging) environments, not in development, where we want to see the full stack traces)
RUN echo "zend.exception_ignore_args = On" > /usr/local/etc/php/conf.d/99-moodle-security.ini