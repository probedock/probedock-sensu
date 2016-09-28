#!/bin/bash

for plugin in `cat images/sensu-server/plugins.txt`; do
  sudo sensu-install -p $plugin
done

for gem in images/sensu-server/gems/*.gem; do
  sudo GEM_PATH=/opt/sensu/embedded/lib/ruby/gems/2.3.0 /opt/sensu/embedded/bin/gem install $gem
done
