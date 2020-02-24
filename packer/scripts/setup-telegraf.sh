#!/usr/bin/env bash

set -euxo pipefail

curl -s "https://dl.influxdata.com/telegraf/releases/telegraf_$1-1_amd64.deb" --output "telegraf_$1-1_amd64.deb"
sudo dpkg -i "telegraf_$1-1_amd64.deb"
rm "telegraf_$1-1_amd64.deb"
sudo systemctl stop telegraf.service
sudo systemctl disable telegraf.service
sudo mv /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf.original
sudo mv /tmp/config/telegraf-$2.conf /etc/telegraf/telegraf.conf
sudo chown -R telegraf:telegraf /etc/telegraf/telegraf.conf
