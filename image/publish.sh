#!/bin/bash

set -euxo pipefail

mkdir partner-utils
cd partner-utils
curl -s -O https://storage.googleapis.com/c2d-install-scripts/partner-utils.tar.gz
tar -xzvf partner-utils.tar.gz
pip3 install --upgrade oauth2client
sudo python setup.py install

echo "Creating the image."
python image_creator.py --project $1 \
    --disk $2 \
    --name influxdata-debian-9-$3 \
    --family "influxdb-enterprise" \
    --description "InfluxData, InfluxDB Enterprise, version $4, based on Debian 9 (stretch), amd64 built on $5" \
    --destination-project "influxdata-public" \
    --license "influxdata-public/influxdb-enterprise-byol"

echo "Cleaning up partner-utils."
cd ..
sudo rm -rf partner-utils
