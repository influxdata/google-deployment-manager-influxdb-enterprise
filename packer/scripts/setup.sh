#!/usr/bin/env bash

set -euxo pipefail

sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo apt-get install -y jq google-cloud-sdk
sleep 15

cp /tmp/scripts/* .
sudo chmod +x ./setup-*

case "${PACKER_BUILD_NAME}" in
    "enterprise-data")
        ./setup-influxdb.sh "${INFLUXDB_VERSION}" data
        sleep 5
        ./setup-telegraf.sh "${TELEGRAF_VERSION}" data;;
    "enterprise-meta")
        ./setup-influxdb.sh "${INFLUXDB_VERSION}" meta
        sleep 5
        ./setup-telegraf.sh "${TELEGRAF_VERSION}" meta;;
esac

sudo mkdir /usr/local/share/licenses
sudo tar xvzf /tmp/licenses.tar.gz --directory /usr/local/share/licenses/
rm /tmp/licenses.tar.gz

rm -r /tmp/scripts /tmp/config
rm .ssh/authorized_keys

sudo chmod +x ./validate.sh
./validate.sh
rm -r ./*.sh
