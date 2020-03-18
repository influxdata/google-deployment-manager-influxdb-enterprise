###
### Mount disk
###
# Uncomment the following line to enable debug output
# set -euxo pipefail

# confirm fstab mounts are created before continuing
sudo mount -a

readonly INFLUX_DIR="/mnt/influxdb"

# mount influxdb volume if it is not already mounted
if [ ! -d "/mnt/influxdb" ]; then
  format_and_mount_disk "influxdb" "${INFLUX_DIR}"
fi

if [ -d "${INFLUX_DIR}/meta" ]; then
  echo "InfluxDB meta node is already configured. Exiting"
  exit
fi

###
### Set IP address as runtime config
###

readonly NODE_PRIVATE_DNS=$(get_hostname)
readonly DEPLOYMENT=$(get_attribute_value "deployment")
readonly LICENSE_KEY=$(get_attribute_value "license-key")

if [ -z "${LICENSE_KEY}" ]; then
  readonly LICENSE_TYPE="marketplace-env = \"gcp\""
else
  readonly LICENSE_TYPE="license-key = \"${LICENSE_KEY}\""
fi

sudo mv /etc/influxdb/influxdb-meta.conf /etc/influxdb/influxdb-meta.conf.backup
echo "# this config was generated by the instance template startup script

# Hostname advertised by this host for remote addresses.  This must be resolvable by all
# other nodes in the cluster.
hostname = \"${NODE_PRIVATE_DNS}\"

[enterprise]
  ${LICENSE_TYPE}

[meta]
  # Directory where cluster meta data is stored.
  dir = \"${INFLUX_DIR}/meta\"
" | sudo tee -a /etc/influxdb/influxdb-meta.conf > /dev/null

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

# allow some time for all nodes to finish entitlement verification
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
