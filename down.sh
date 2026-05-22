#!/bin/sh -e

# Load environment variables
. ./.env

if [ "$DEPLOY_ENV" = "local" ]; then
  compose_env="compose.local.yaml"
else
  compose_env="compose.staging.yaml"
fi

echo "Stopping $DEPLOY_ENV containers..."
docker compose -f compose.yaml -f "$compose_env" down "$@"