#!/bin/bash

for plugin in `cat /plugins.txt`; do
  sensu-install -p $plugin
done
