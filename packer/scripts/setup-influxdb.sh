#!/usr/bin/env bash

set -euxo pipefail

readonly version="${1}"
readonly type="${2}"

case "${type}" in
    "data")
        download_path="enterprise"
        package_name="influxdb-data"
        package_version="${version}-c${version}"
        service_name="influxdb"
        config_filename="influxdb.conf";;
    "meta")
        download_path="enterprise"
        package_name="influxdb-meta"
        package_version="${version}-c${version}"
        service_name="influxdb-meta"
        config_filename="influxdb-meta.conf";;
esac

curl -s "https://dl.influxdata.com/${download_path}/releases/${package_name}_${package_version}_amd64.deb" --output "${package_name}_${package_version}_amd64.deb"
sudo dpkg -i "${package_name}_${package_version}_amd64.deb"
rm "${package_name}_${package_version}_amd64.deb"
sudo systemctl stop "${service_name}.service"
sudo systemctl disable "${service_name}.service"
cat "/tmp/config/influxdb.conf" "/etc/influxdb/${config_filename}" > "${config_filename}.tmp"
sudo rm "/etc/influxdb/${config_filename}"
sudo mv "${config_filename}.tmp" "/etc/influxdb/${config_filename}"
sudo chown -R influxdb:influxdb "/etc/influxdb/${config_filename}"
