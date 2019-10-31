#!/usr/bin/env bash

set -euxo pipefail

curl -s "https://dl.influxdata.com/influxdb/releases/influxdb_$1_amd64.deb" --output "influxdb_$1_amd64.deb"
sudo dpkg -i "influxdb_$1_amd64.deb"
rm "influxdb_$1_amd64.deb"
sudo systemctl stop influxdb.service
sudo systemctl disable influxdb.service
sudo mv /etc/influxdb/influxdb.conf /etc/influxdb/influxdb.conf.original
sudo mv /tmp/config/influxdb-monitor.conf /etc/influxdb/influxdb.conf
sudo chown -R influxdb:influxdb /etc/influxdb/influxdb.conf
