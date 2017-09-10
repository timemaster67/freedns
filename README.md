# FreeDns

Shell script using Systemd for updating your domains at http://freedns.afraid.org. Uses opendns and dig to resolve the external IP address. Only updates afraid.org when the external IP has changed.

## Requirements
        Dig
        Wget

## Install
        $ sudo ./setup.sh

## Setup
1. Edit the configuration file, /etc/free_dns.conf

- Start the FreeDns Systemd service

        $ sudo systemctl restart freedns.service