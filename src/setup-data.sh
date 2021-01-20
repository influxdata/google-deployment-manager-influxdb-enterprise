#!/bin/bash

# Uncomment the following line to enable debug output
set -euxo pipefail

signal_failure() {
  set_rtc_var_text "${DEPLOYMENT}-rtc" "startup-status/failure/signal" "FAILURE"
}
trap signal_failure ERR

# confirm fstab mounts are created before continuing
sudo mount -a

readonly INFLUX_DIR="/influxdb"
readonly DATA_ENV_FILE="/etc/default/influxdb"
readonly HOSTNAME=$(get_hostname)
readonly DEPLOYMENT=$(get_attribute_value "deployment")
readonly LICENSE_KEY=$(get_attribute_value "license-key")

# Create etc/default/influxdb file to over-ride configuration defaults.
if touch "${DATA_ENV_FILE}"; then
  sudo tee -a "${DATA_ENV_FILE}" <<EOF > /dev/null
INFLUXDB_HOSTNAME="${HOSTNAME}"
INFLUXDB_META_DIR="/influxdb/meta"
INFLUXDB_DATA_DIR="/influxdb/data"
INFLUXDB_DATA_WAL_DIR="/influxdb/wal"
INFLUXDB_DATA_QUERY_LOG_ENABLED="false"
INFLUXDB_DATA_INDEX_VERSION="tsi1"
INFLUXDB_HTTP_AUTH_ENABLED="true"
INFLUXDB_HTTP_FLUX_ENABLED="true"
INFLUXDB_CLUSTER_LOG_QUERIES_AFTER="10s"
INFLUXDB_ANTI_ENTROPY_ENABLED="true"
INFLUXDB_HINTED_HANDOFF_DIR="/influxdb/hh"
EOF
else
  echo  "cannot create /etc/default/influxdb file. manual configuration required"
  exit 1
fi

if [ -z "${LICENSE_KEY}" ]; then
  printf "INFLUXDB_ENTERPRISE_MARKETPLACE_ENV=\"gcp\"" >> "${DATA_ENV_FILE}"
else
  printf "INFLUXDB_ENTERPRISE_LICENSE_KEY=\"%s\"" "${LICENSE_KEY}" >> "${DATA_ENV_FILE}"
fi

# Mount influxdb volume if it is not already mounted
if [ ! -d "${INFLUX_DIR}" ]; then
  format_and_mount_disk "influxdb" "${INFLUX_DIR}"
fi

if [ -d "${INFLUX_DIR}/data" ]; then
  echo "InfluxDB Enterprise data node is already configured. exiting"
  exit
fi

sudo mkdir "${INFLUX_DIR}/meta" "${INFLUX_DIR}/data" "${INFLUX_DIR}/wal" "${INFLUX_DIR}/hh"
sudo chown -R influxdb:influxdb "${INFLUX_DIR}"

sudo systemctl enable influxdb
sudo systemctl start influxdb

set_rtc_var_text "${DEPLOYMENT}-rtc" "nodes/data/${HOSTNAME}" "$(hostname)"

printf "instance setup complete. waiting for meta node leader to initialize cluster"
