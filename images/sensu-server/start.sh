#!/bin/bash
set -e

case $SENSU_ROLE in
	"server")
		# Remove the check configuration files
		find /etc/sensu/conf.d -name "check*.json" -delete

		# Create the new ones
		for filename in /sensu/checks/*.json; do
			handlebars /sensu/env.json < $filename > /etc/sensu/conf.d/$(basename "$filename")
		done

		# Remove the check configuration files
		find /etc/sensu/conf.d -name "*handler.json" -delete

		# Create the new ones
		for filename in /sensu/handlers/*.json; do
			handlebars /sensu/env.json < $filename > /etc/sensu/conf.d/$(basename "$filename")
		done

		/opt/sensu/bin/sensu-server -d /etc/sensu/conf.d
	;;
	"api") /opt/sensu/bin/sensu-api -d /etc/sensu/conf.d;;
	*) echo "no such role"
esac

exec "$@"
