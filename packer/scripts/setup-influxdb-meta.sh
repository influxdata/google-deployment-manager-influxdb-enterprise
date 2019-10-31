#!/usr/bin/env bash

set -euxo pipefail

curl -s "https://dl.influxdata.com/enterprise/releases/influxdb-meta_$1-c$1_amd64.deb" --output "influxdb-meta_$1-c$1_amd64.deb"
sudo dpkg -i "influxdb-meta_$1-c$1_amd64.deb"
rm "influxdb-meta_$1-c$1_amd64.deb"
sudo systemctl stop influxdb-meta.service
sudo systemctl disable influxdb-meta.service
sudo mv /etc/influxdb/influxdb-meta.conf /etc/influxdb/influxdb-meta.conf.original
sudo mv /tmp/config/influxdb-meta.conf /etc/influxdb/influxdb-meta.conf
sudo chown -R influxdb:influxdb /etc/influxdb/influxdb-meta.conf
