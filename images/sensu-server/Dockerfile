FROM node:6.6.0-wheezy

ENV SENSU_ROLE server

RUN npm install -g handlebars-cmd

RUN apt-get update && apt-get install -y wget apt-transport-https

RUN wget -q https://sensu.global.ssl.fastly.net/apt/pubkey.gpg -O- | apt-key add -
RUN echo "deb     https://sensu.global.ssl.fastly.net/apt sensu main" | tee /etc/apt/sources.list.d/sensu.list
RUN apt-get update && apt-get install -y sensu

RUN apt-get clean

COPY config/ /etc/sensu/conf.d

COPY start.sh /start.sh

ENTRYPOINT ["/start.sh"]
