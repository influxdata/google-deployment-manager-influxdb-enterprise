#!/usr/bin/env bash

set -euxo pipefail

readonly version="${1}"
readonly type="${2}"

curl -s "https://dl.influxdata.com/telegraf/releases/telegraf_${version}-1_amd64.deb" --output "telegraf_${version}-1_amd64.deb"
sudo dpkg -i "telegraf_${version}-1_amd64.deb"
rm "telegraf_${version}-1_amd64.deb"
sudo systemctl stop telegraf.service
sudo systemctl disable telegraf.service
sudo mv /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf.original
sudo mv "/tmp/config/telegraf-${type}.conf" /etc/telegraf/telegraf.conf
sudo chown -R telegraf:telegraf /etc/telegraf/telegraf.conf
