# Probe Dock Sensu monitoring solution

> A dockerized Sensu installation of Sensu Server and API with Uchiwa as the web UI

The idea is to deploy in your infrastructure the Dockerized Sensu setup and then
to install and configure your clients to connect to this infra.

## Sensu API, Server and Uchiwa UI for Sensu installation

1. Clone this repository

2. Run the `start.sh` script

If everything is working, you should be able to connect to `http://<ip>:9980` and
see the Sensu community edition UI. You will see any of your Sensu clients appearing
there once correctly setup and running.

## Sensu client installation on VM Host

1. Clone this repository

2. Install Sensu on host VM

```bash
sudo ./install.sh
```

3. Update the `/etc/sensu/conf.d/client.json` configuration file:

  * `<hostname>` The name of the host that will be appearing in the uchiwa UI
  * `<hostip>` The IP of the host that will be appearing in the uchiwa UI
  * `<environment>` The environment (production, development, ...)

4. Update the `/etc/sensu/conf.d/redis.json` configuration file:

  * `<redishostip>` The IP of the redis instance used by sensu.

5. It's time to run the Sensu client

```bash
sudo service sensu-client start
```
