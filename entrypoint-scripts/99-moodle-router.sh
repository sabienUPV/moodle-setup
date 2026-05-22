#!/bin/sh
# ---------------------------------------------------------
# Moodle Router Configuration Script
# This script is automatically executed by the base image
# via the docker-entrypoint.d mechanism.
# It ensures clean URLs work by redirecting traffic to r.php
# ---------------------------------------------------------

echo "Injecting Moodle Router configuration for Apache..."

cat <<EOF > /etc/apache2/conf-enabled/moodle-router.conf
<Directory /var/www/html>
    AllowOverride All
    Require all granted
    DirectoryIndex index.php
    FallbackResource /r.php
</Directory>
EOF

echo "Moodle Router configuration successfully applied."