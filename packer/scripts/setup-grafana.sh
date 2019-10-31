#!/usr/bin/env bash

set -euxo pipefail

curl -s "https://dl.grafana.com/oss/release/grafana_$1_amd64.deb" --output "grafana_$1_amd64.deb"
sudo dpkg -i "grafana_$1_amd64.deb"
rm "grafana_$1_amd64.deb"
sudo systemctl stop grafana
sudo systemctl disable grafana
