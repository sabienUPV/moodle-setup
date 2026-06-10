#!/bin/sh -e

# Load environment variables
. ./.env

# Startup logic
if [ "$DEPLOY_ENV" = "local" ]; then
  compose_env="compose.local.yaml"
  echo 'Starting LOCAL environment (Moodle directly on port 8080)...'
else
  compose_env="compose.staging.yaml"
  echo 'Starting STAGING environment (Moodle + Nginx Proxy Manager)...'
fi

docker compose -f compose.yaml -f "$compose_env" up -d "$@"
