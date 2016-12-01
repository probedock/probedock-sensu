#!/bin/bash
set -e

export PGPASSWORD="$LAIR_DATABASE_PASSWORD"
until psql -h lair_db -U "$LAIR_DATABASE_NAME" -c '\l'; do
  >&2 echo "Postgres is unavailable - waiting"
  sleep 1
done

>&2 echo "Postgres is up"

until (echo > "/dev/tcp/sensu-redis/6379") >/dev/null 2>&1; do
  >&2 echo "Redis is unavailable - waiting"
  sleep 1
done

>&2 echo "Redis is up"

exec "$@"
