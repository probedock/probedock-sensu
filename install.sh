#!/bin/bash

wget -q https://sensu.global.ssl.fastly.net/apt/pubkey.gpg -O- | apt-key add -

echo "deb     https://sensu.global.ssl.fastly.net/apt sensu main" | tee /etc/apt/sources.list.d/sensu.list

apt-get update

apt-get install sensu

cp config-templates/*.json /etc/sensu/conf.d

update-rc.d sensu-client defaults
