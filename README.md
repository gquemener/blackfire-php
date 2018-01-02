# Blackfire agent installation troubleshoot

## Description

As described [in the doc](https://blackfire.io/docs/up-and-running/installation#install-agent-debian), after installing
the blackfire agent, one is suppose to register its credentials in order to link the agent with his blackfire account.

Unfortunately, while using a non-interactive process, like a docker image build, the registration through the
command line does not work. Basically, I would expect to be able to configure the server-id and server-token through
command line **without** using an interactive shell (which is required by `-register`).

## Steps to reproduce

Build the docker image shipped in this repo:

```
$ docker build -t blackfire-php .
```

Run a container using this image:

```
$ docker run --rm -it -e BLACKFIRE_AGENT_SERVER_ID=b6a6558e-2301-4f2e-878f-3ab024b3b4d1 -e BLACKFIRE_AGENT_SERVER_TOKEN=c41597df5f0a29244f2f7e903f5f0fca2249b1a07b25a7d3aece07e768518828 blackfire-php php -v
[2018-01-02T21:19:50Z] DEBUG: Using CLI flags for 'log-file' configuration entry.
[2018-01-02T21:19:50Z] DEBUG: Using CLI flags for 'log-level' configuration entry.
[2018-01-02T21:19:50Z] DEBUG: Using CLI flags for 'server-id' configuration entry.
[2018-01-02T21:19:50Z] DEBUG: Using CLI flags for 'server-token' configuration entry.
[2018-01-02T21:19:50Z] DEBUG: Using default configuration file for 'ca-cert' configuration entry.
[2018-01-02T21:19:50Z] DEBUG: Using default configuration file for 'collector' configuration entry.
[2018-01-02T21:19:50Z] DEBUG: Using default configuration file for 'http-proxy' configuration entry.
[2018-01-02T21:19:50Z] DEBUG: Using default configuration file for 'https-proxy' configuration entry.
[2018-01-02T21:19:50Z] DEBUG: Using default configuration file for 'socket' configuration entry.
[2018-01-02T21:19:50Z] DEBUG: Using default configuration file for 'spec' configuration entry.
[2018-01-02T21:19:50Z] DEBUG: blackfire-agent 1.15.0 linux amd64 gc 2017-11-16T21:19:50+0000
[2018-01-02T21:19:50Z] DEBUG: Retrieving public keys from API
[2018-01-02T21:19:50Z] DEBUG: Fetching public keys from API
[2018-01-02T21:19:50Z] DEBUG: Sending request GET https://blackfire.io/agent-api/v1/public-keys
[2018-01-02T21:19:52Z] DEBUG: API answered with status code: 200
[2018-01-02T21:19:52Z] DEBUG: Unmarshalled json result: &{[{RWT1ciFcmJUimhYCV1cY49BSsfqVDrt5aVARTzTCuxvJhJxpQJmg2bUd RWTscN69dTZ4ViY4vrLQ7f_upHWcAgpopQc_m112Mp9wFJbtFquOuG7u16TP6Gljf1iP70IQKkXButakdkzRU\X_ejhbXYFgQ8= 20180411}]}
[2018-01-02T21:19:52Z] DEBUG: Started verification of '1' public keys
[2018-01-02T21:19:52Z] DEBUG: Retrieving specs from the API
[2018-01-02T21:19:52Z] DEBUG: Fetching specs from API
[2018-01-02T21:19:52Z] DEBUG: Sending request GET https://blackfire.io/agent-api/v1/specs
[2018-01-02T21:19:53Z] DEBUG: API answered with status code: 200
[2018-01-02T21:19:53Z] DEBUG: Merging spec from the API and local spec
[2018-01-02T21:19:53Z] DEBUG: New value of DefaultSpec.LastMaxAge:  24h0m0s
[2018-01-02T21:19:53Z] DEBUG: Listening for connections on 'unix:///var/run/blackfire/agent.sock'
[2018-01-02T21:19:53Z] ERROR: Error while trying to listen for connections on 'unix:///var/run/blackfire/agent.sock': listen unix /var/run/blackfire/agent.sock: bind: no such file or directory
[....] Restarting Blackfire Agent: blackfire-agentThe server ID parameter is not set. Please run 'blackfire-agent -register' to configure it.
usage /usr/bin/blackfire-agent [options]
--collector="https://blackfire.io": Sets the URL of Blackfire's data collector
--config="/etc/blackfire/agent": Sets the path to the configuration file
-d: Prints the current configuration
--http-proxy="": Sets the http proxy to use
--https-proxy="": Sets the https proxy to use
--log-file="stderr": Sets the path of the log file. Use stderr to log to stderr
--log-level="1": log verbosity level (4: debug, 3: info, 2: warning, 1: error)
--register: Helps you with registering the agent
--server-id="": Sets the server id used to authenticate with Blackfire API
--server-token="": Sets the server token used to authenticate with Blackfire API. It is unsafe to set this from the command line
--socket="unix:///var/run/blackfire/agent.sock": Sets the socket the agent should read traces from. Possible value can be a unix socket or a TCP address. ie: unix:///var/run/blackfire/agent.sock or tcp://127.0.0.1:8307
--test: Tests the configuration
--timeout="15s": Sets the Blackfire connection timeout
-v: Prints the version number
failed!
PHP 7.1.11 (cli) (built: Nov  4 2017 10:16:07) ( NTS )
Copyright (c) 1997-2017 The PHP Group
Zend Engine v3.1.0, Copyright (c) 1998-2017 Zend Technologies
```

## Expected result
The result should be the same as the one produced by `blackfire-agent -register`:

```
Verifying credentials...
------------------------------------------------------------------------------
The following configuration has been updated successfully
/etc/blackfire/agent
Please now restart the blackfire-agent service to use the generated configuration

sudo /etc/init.d/blackfire-agent restart

Thank you for using Blackfire
------------------------------------------------------------------------------
```

One other solution could be to directly update the config file (without prompting values) when using the `-register`
option **combined** with `--server-id` and/or `--server-token`.

## Workaround

So far, I've managed to configure this value by running the following commands in `entrypoint.sh`:

```
$ sed -i "s/^server-id=.*/server-id=${BLACKFIRE_AGENT_SERVER_ID}/" /etc/blackfire/agent
$ sed -i "s/^server-token=.*/server-token=${BLACKFIRE_AGENT_SERVER_TOKEN}/" /etc/blackfire/agent
$ /etc/init.d/blackfire-agent restart
```
