#!/bin/bash

wget -q https://sensu.global.ssl.fastly.net/apt/pubkey.gpg -O- | apt-key add -

echo "deb     https://sensu.global.ssl.fastly.net/apt sensu main" | tee /etc/apt/sources.list.d/sensu.list

apt-get update

apt-get install sensu

cp config-templates/*.json /etc/sensu/conf.d

for plugin in `cat images/sensu-server/plugins.txt`; do
  sensu-install -p $plugin
done

update-rc.d sensu-client defaults
