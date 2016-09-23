FROM node:6.6.0-wheezy

ENV SENSU_ROLE server

RUN npm install -g handlebars-cmd

RUN apt-get update && apt-get install -y wget apt-transport-https

RUN wget -q https://sensu.global.ssl.fastly.net/apt/pubkey.gpg -O- | apt-key add -
RUN echo "deb     https://sensu.global.ssl.fastly.net/apt sensu main" | tee /etc/apt/sources.list.d/sensu.list
RUN apt-get update && apt-get install -y sensu

RUN apt-get clean

COPY plugins.txt /plugins.txt
COPY install-plugins.sh /install-plugins.sh
COPY gems/ /gems

RUN /install-plugins.sh \
  && rm plugins.txt install-plugins.sh \
  && rm -rf /gems

COPY config/ /baseconf

COPY start.sh /start.sh

CMD ["/start.sh"]
