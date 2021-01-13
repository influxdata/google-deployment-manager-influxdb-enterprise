#!/bin/bash

# Uncomment the following line to enable debug output
# set -euxo pipefail

# confirm fstab mounts are created before continuing
sudo mount -a

readonly INFLUX_DIR="/mnt/influxdb"
readonly META_ENV_FILE="/etc/default/influxdb-meta"
readonly HOSTNAME=$(get_hostname)
readonly DEPLOYMENT=$(get_attribute_value "deployment")
readonly LICENSE_KEY=$(get_attribute_value "license-key")
readonly LOG_FILE="/var/log/influxdb-setup-meta.log"

log() {
  while read -r
  do
    printf "%(%T)T %s\n" -1 "stdout: $REPLY" | tee -a "${LOG_FILE}"
  done
}
logerr() {
  while read -r
  do
    printf "%(%T)T %s\n" -1 "err: $REPLY" >> "${LOG_FILE}"
  done
}

# Create etc/default/influxdb file to over-ride configuration defaults
if touch "${META_ENV_FILE}"; then
  sudo tee -a "${META_ENV_FILE}" <<EOF > /dev/null
INFLUXDB_HOSTNAME="${HOSTNAME}"
INFLUXDB_META_DIR="/influxdb/meta"
EOF
else
  logerr  "cannot create /etc/default/influxdb file. manual configuration required"
  exit 1
fi

if [ -z "${LICENSE_KEY}" ]; then
  printf "INFLUXDB_ENTERPRISE_MARKETPLACE_ENV=\"gcp\"" >> "${META_ENV_FILE}"
else
  printf "INFLUXDB_LICENSE_KEY=\"%s\"" "${LICENSE_KEY}" >> "${META_ENV_FILE}"
fi

# Mount influxdb volume if it is not already mounted
if [ ! -d "/mnt/influxdb" ]; then
  format_and_mount_disk "influxdb" "${INFLUX_DIR}"
fi

if [ -d "${INFLUX_DIR}/meta" ]; then
  log "InfluxDB Enterprise meta node is already configured. exiting"
  exit
fi

sudo mkdir "${INFLUX_DIR}/meta"
sudo chown -R influxdb:influxdb "${INFLUX_DIR}"

sudo systemctl enable influxdb-meta
sudo systemctl start influxdb-meta

set_rtc_var_text "${DEPLOYMENT}-rtc" "internal-dns/meta/${HOSTNAME}" "${NODE_PRIVATE_DNS}"

wait_for_rtc_waiter_success "${DEPLOYMENT}-rtc" "${DEPLOYMENT}-rtc-cluster-waiter" "250"

readonly META_LEADER="$(filter_rtc_var "${DEPLOYMENT}-rtc" "internal-dns/meta/" | head -n 1)"

if [ "${HOSTNAME}" != "${META_LEADER}" ]; then
  exit
fi

# Allow some time for all nodes to finish entitlement verification
sleep 30

filter_rtc_var "${DEPLOYMENT}-rtc" "internal-dns/meta/" | while read line; do
  influxd-ctl add-meta $(get_rtc_var_text "${DEPLOYMENT}-rtc" "internal-dns/meta/${line}"):8091
done

filter_rtc_var "${DEPLOYMENT}-rtc" "internal-dns/data/" | while read line; do
  influxd-ctl add-data $(get_rtc_var_text "${DEPLOYMENT}-rtc" "internal-dns/data/${line}"):8088
done

readonly USERNAME=$(get_attribute_value "admin-user")
readonly PASSWORD=$(get_attribute_value "admin-password")
readonly REMOTE_HOST=$(filter_rtc_var "${DEPLOYMENT}-rtc" "internal-dns/data/" | head -n 1)

payload="q=CREATE USER ${USERNAME} WITH PASSWORD '${PASSWORD}' WITH ALL PRIVILEGES"
curl -s -k -X POST \
    -d "${payload}" \
    "http://${REMOTE_HOST}:8086/query"

set_rtc_var_text "${DEPLOYMENT}-rtc" "startup-status/success/test" "SUCCESS"
