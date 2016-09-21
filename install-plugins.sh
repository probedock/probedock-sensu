#!/bin/bash

for plugin in `cat images/sensu-server/plugins.txt`; do
  sensu-install -p $plugin
done
