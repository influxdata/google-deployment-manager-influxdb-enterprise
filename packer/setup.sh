#!/bin/bash

set -euxo pipefail

# unpack license file and MPL source code to /usr/local/share/licenses
sudo mkdir /usr/local/share/licenses
sudo tar xvzf licenses.tar.gz --directory /usr/local/share/licenses/
rm licenses.tar.gz

# install InfluxDB Enterprise data node package
curl -s "https://dl.influxdata.com/enterprise/releases/influxdb-data_$1_amd64.deb" --output "influxdb-data_$1_amd64.deb"
sudo dpkg -i "influxdb-data_$1_amd64.deb"
sudo systemctl disable influxdb
rm "influxdb-data_$1_amd64.deb"

# install InfluxDB Enterprise meta node package
curl -s "https://dl.influxdata.com/enterprise/releases/influxdb-meta_$1_amd64.deb" --output "influxdb-meta_$1_amd64.deb"
sudo dpkg -i "influxdb-meta_$1_amd64.deb"
sudo systemctl disable influxdb-meta
rm "influxdb-meta_$1_amd64.deb"

# install Telegraf package
curl -s "https://dl.influxdata.com/telegraf/releases/telegraf_$2-1_amd64.deb" --output "telegraf_$2-1_amd64.deb"
sudo dpkg -i telegraf_$2-1_amd64.deb
sudo systemctl disable telegraf
rm "telegraf_$2-1_amd64.deb"

# generate Telegraf config
# TODO(Gunnar): replace with an actual configuration for monitoring InfluxDB Enterprise
telegraf --input-filter cpu:mem:diskio config > telegraf.conf
sudo mv telegraf.conf /etc/telegraf/telegraf.conf
