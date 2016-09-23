#!/bin/bash

for plugin in `cat /plugins.txt`; do
  sensu-install -p $plugin
done


for gem in /gems/*.gem; do
  GEM_PATH=/opt/sensu/embedded/lib/ruby/gems/2.3.0 /opt/sensu/embedded/bin/gem install $gem
done
