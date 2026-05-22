#!/bin/sh -e

. ./.env

if [ "$DEPLOY_ENV" = "local" ]; then
  compose_env="compose.local.yaml"
else
  compose_env="compose.staging.yaml"
fi

echo "Deteniendo contenedores de $DEPLOY_ENV..."
docker compose -f compose.yaml -f "$compose_env" down "$@"