#!/bin/bash

# Uncomment the following line to enable debug output
# set -euxo pipefail

signal_failure() {
  set_rtc_var_text "${DEPLOYMENT}-rtc" "startup-status/failure/signal" "FAILURE"
}
trap signal_failure ERR

# confirm fstab mounts are created before continuing
sudo mount -a

readonly INFLUX_DIR="/influxdb"
readonly META_ENV_FILE="/etc/default/influxdb-meta"
readonly HOSTNAME=$(get_hostname)
readonly DEPLOYMENT=$(get_attribute_value "deployment")
readonly LICENSE_KEY=$(get_attribute_value "license-key")

if [ -d "${INFLUX_DIR}/meta" ]; then
  echo "InfluxDB Enterprise meta node is already configured. exiting"
  exit
fi

# Mount influxdb volume if it is not already mounted
if [ ! -d "${INFLUX_DIR}" ]; then
  format_and_mount_disk "influxdb" "${INFLUX_DIR}"
fi

# Create etc/default/influxdb file to over-ride configuration defaults
if touch "${META_ENV_FILE}"; then
  sudo tee -a "${META_ENV_FILE}" <<EOF > /dev/null
INFLUXDB_HOSTNAME="${HOSTNAME}"
INFLUXDB_META_DIR="/influxdb/meta"
EOF
else
  echo  "cannot create /etc/default/influxdb file. manual configuration required"
  exit 1
fi

if [ -z "${LICENSE_KEY}" ]; then
  printf "INFLUXDB_ENTERPRISE_MARKETPLACE_ENV=\"gcp\"" >> "${META_ENV_FILE}"
else
  printf "INFLUXDB_ENTERPRISE_LICENSE_KEY=\"%s\"" "${LICENSE_KEY}" >> "${META_ENV_FILE}"
fi

if [ ! -d "${INFLUX_DIR}/meta" ]; then
  sudo mkdir "${INFLUX_DIR}/meta"
  sudo chown -R influxdb:influxdb "${INFLUX_DIR}"
else
  echo "InfluxDB Enterprise meta node is already configured. exiting"
  exit
fi

sudo systemctl enable influxdb-meta
sudo systemctl start influxdb-meta

printf "instance setup complete"

set_rtc_var_text "${DEPLOYMENT}-rtc" "nodes/meta/${HOSTNAME}" "$(hostname)"

wait_for_rtc_waiter_success "${DEPLOYMENT}-rtc" "${DEPLOYMENT}-rtc-cluster-nodes-waiter"

readonly META_LEADER="$(filter_rtc_var "${DEPLOYMENT}-rtc" "nodes/meta/" | head -n 1)"
# readonly META_LEADER="$(filter_rtc_var "${DEPLOYMENT}-rtc" "${DEPLOYMENT}-meta-vm-[^.]+" | head -n 1)"

if [ "${HOSTNAME}" != "${META_LEADER}" ]; then
  printf "cluster initialization will occur on %s" "${META_LEADER}"
  exit
else
  # Meta leader initializes the cluster with all nodes
  filter_rtc_var "${DEPLOYMENT}-rtc" "nodes/meta/" | while read -r line; do
    influxd-ctl add-meta "${line}:8091"
  done

  filter_rtc_var "${DEPLOYMENT}-rtc" "nodes/data/" | while read -r line; do
    influxd-ctl add-data "${line}:8088"
  done

  readonly USERNAME=$(get_attribute_value "admin-user")
  readonly PASSWORD=$(get_attribute_value "admin-password")
  readonly REMOTE_HOST=$(filter_rtc_var "${DEPLOYMENT}-rtc" "nodes/data/" | head -n 1)

  payload="q=CREATE USER ${USERNAME} WITH PASSWORD '${PASSWORD}' WITH ALL PRIVILEGES"
  curl -s -k -X POST \
      -d "${payload}" \
      "http://${REMOTE_HOST}:8086/query"

  set_rtc_var_text "${DEPLOYMENT}-rtc" "startup-status/success/signal" "SUCCESS"

  printf "cluster initialization complete"
fi
