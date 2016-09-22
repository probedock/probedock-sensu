#!/bin/bash

for plugin in `cat images/sensu-server/plugins.txt`; do
  sensu-install -p $plugin
done

for plugin in `ls sensu-data/plugins`; do
  sudo cp sensu-data/plugins/$plugin /etc/sensu/plugins
done
