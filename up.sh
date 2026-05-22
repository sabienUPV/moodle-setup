#!/bin/sh -e

. ./.env

if [ "$DEPLOY_ENV" = "local" ]; then
  compose_env="compose.local.yaml"
  echo 'Levantando entorno LOCAL (Moodle directo en puerto 8080)...'
else
  compose_env="compose.staging.yaml"
  echo 'Levantando entorno STAGING (Moodle + Nginx Proxy Manager)...'
fi

docker compose -f compose.yaml -f "$compose_env" up -d "$@"