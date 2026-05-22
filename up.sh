#!/bin/sh -e

# Load environment variables
. ./.env

# Process flags
init_mode=false
for arg in "$@"; do
  if [ "$arg" = "--init" ]; then
    init_mode=true
    shift # Remove the --init argument so it's not passed to docker compose
  fi
done

# Initialization logic
if [ "$init_mode" = true ]; then
  echo "Starting directory setup to avoid root permission issues..."
  
  # Create directories for volumes
  mkdir -p bind-mounts/moodledata bind-mounts/mariadb_data bind-mounts/proxy/data bind-mounts/proxy/letsencrypt

  # Change the owner of Moodle's data folder to user 33 (www-data)
  # so the web server has the necessary permissions to read/write files
  sudo chown -R 33:33 bind-mounts/moodledata
  
  # Clone Moodle if the html directory does not exist or is empty
  if [ ! -d "bind-mounts/html" ] || [ -z "$(ls -A bind-mounts/html)" ]; then
    echo "Cloning official Moodle repository (5.2 Current Stable branch)..."
    git clone --depth=1 -b MOODLE_502_STABLE --single-branch git://git.moodle.org/moodle.git bind-mounts/html
  else
    echo "The 'bind-mounts/html' directory already exists. Skipping clone."
  fi

  # Copy configuration
  if [ -f "config.php" ]; then
    echo "Copying config.php to bind-mounts/html/..."
    cp config.php bind-mounts/html/config.php
  else
    echo "⚠️ Warning: config.php not found in the project root."
  fi
  
  # Run Composer to install PHP dependencies (downloading composer.phar on the fly)
  echo "Installing Composer dependencies..."
  docker compose run --rm -w /var/www/html moodle sh -c "\
    php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\" && \
    php composer-setup.php && \
    php composer.phar install --no-dev --classmap-authoritative && \
    rm composer-setup.php composer.phar"

  echo "Initialization completed."
fi

# Startup logic
if [ "$DEPLOY_ENV" = "local" ]; then
  compose_env="compose.local.yaml"
  echo 'Starting LOCAL environment (Moodle directly on port 8080)...'
else
  compose_env="compose.staging.yaml"
  echo 'Starting STAGING environment (Moodle + Nginx Proxy Manager)...'
fi

docker compose -f compose.yaml -f "$compose_env" up -d "$@"