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
  mkdir -p moodledata mariadb_data proxy/data proxy/letsencrypt

  # Change the owner of Moodle's data folder to user 33 (www-data)
  # so the web server has the necessary permissions to read/write files
  sudo chown -R 33:33 moodledata
  
  # Clone Moodle if the html directory does not exist or is empty
  if [ ! -d "html" ] || [ -z "$(ls -A html)" ]; then
    echo "Cloning official Moodle repository (5.2 Current Stable branch)..."
    git clone --depth=1 -b MOODLE_502_STABLE --single-branch https://github.com/moodle/moodle.git html
  else
    echo "The 'html' directory already exists. Skipping clone."
  fi

  # Copy configuration
  if [ -f "config.php" ]; then
    echo "Copying config.php to html/..."
    cp config.php html/config.php
  else
    echo "⚠️ Warning: config.php not found in the project root."
  fi

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