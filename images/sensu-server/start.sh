#!/bin/bash
set -e

# Remove configuration files
find /etc/sensu/conf.d -name "*.json" -delete

# Copy shared configuration
cp /baseconf/redis.json /etc/sensu/conf.d
cp /baseconf/transport.json /etc/sensu/conf.d

case $SENSU_ROLE in
	"server")
		# Create the new ones
		for filename in /sensu/checks/*.json; do
			handlebars /sensu/env.json < $filename > /etc/sensu/conf.d/$(basename "$filename")
		done

		# Create the new ones
		for filename in /sensu/handlers/*.json; do
			handlebars /sensu/env.json < $filename > /etc/sensu/conf.d/$(basename "$filename")
		done

		# Copy api config
		cp /baseconf/api-server.json /etc/sensu/conf.d/api.json

		/opt/sensu/bin/sensu-server -d /etc/sensu/conf.d
	;;
	"api")
		cp /baseconf/api.json /etc/sensu/conf.d

		/opt/sensu/bin/sensu-api -d /etc/sensu/conf.d
	;;
	*) echo "no such role"
esac

exec "$@"
