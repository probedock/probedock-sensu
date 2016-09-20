#!/bin/bash
set -e

case $SENSU_ROLE in
	"server") /opt/sensu/bin/sensu-server -d /etc/sensu/conf.d;;
	"api") /opt/sensu/bin/sensu-api -d /etc/sensu/conf.d;;
	*) echo "no such role"
esac

exec "$@"
