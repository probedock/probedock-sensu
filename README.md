# Probe Dock Sensu monitoring solution

> A dockerized Sensu installation of Sensu Server and API with Uchiwa as the web UI

The idea is to deploy in your infrastructure the Dockerized Sensu setup and then
to install and configure your clients to connect to this infra.

## Sensu API, Server and Uchiwa UI for Sensu installation

### Pre-requisites

For the `sensu-server` component, we need to create a Docker volume. It is expected
to have a directory `/sensu`.

In the `/sensu` directory, create the file `env.json` which will be used by `sensu-server`
to create the configuration files at Docker container runtime. This file aims to contain
sensitive configuration values like `tokens`, `passwords`, `webhook urls`.

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

## Install a new checks

1. Go to the http://sensu-plugins.io/ website to choose the checks you need

2. Create the configuration check following the sensu documentation:

  * https://sensuapp.org/docs/0.26/guides/getting-started/intro-to-checks.html
  * https://sensuapp.org/docs/0.26/reference/checks.html

  **Remark**: You need to create your check in `sensu-config` directory

3. Update your sensu server setup

  1. Update your repo (`git pull`)

  2. Re-run the `start.sh` script

4. On each node of your infra, run:

  ```
  sudo sensu-install -p <check_name>:<check_version>

  # Example:
  sudo sensu-install -p disk-checks:2.0.1
  ```

5. [Optional] To reproduce the setup, add the check to the `checks.txt` file
