#!/bin/sh
set -e

until (echo > "/dev/tcp/sensu-api/4567") >/dev/null 2>&1; do
  >&2 echo "Redis is unavailable - waiting"
  sleep 1
done

>&2 echo "Redis is up"

exec "$@"
