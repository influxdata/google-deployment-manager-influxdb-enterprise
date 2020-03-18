###
### Mount disk
###

# Uncomment the following line to enable debug output
# set -euxo pipefail

# confirm fstab mounts are created before continuing
sudo mount -a

readonly INFLUX_DIR="/mnt/influxdb"

# mount influxdb volume if it is not already mounted
if [ ! -d "${INFLUX_DIR}" ]; then
  format_and_mount_disk "influxdb" "${INFLUX_DIR}"
fi

if [ -d "${INFLUX_DIR}/data" ]; then
  echo "InfluxDB data node is already configured. Exiting"
  exit
fi

###
### Set IP address as runtime config
###

readonly NODE_PRIVATE_DNS=$(get_hostname)
readonly DEPLOYMENT=$(get_attribute_value "deployment")
readonly LICENSE_KEY=$(get_attribute_value "license-key")

###
### Set license type {license-key or marketplace-env}
###

if [ -z "${LICENSE_KEY}" ]; then
  readonly LICENSE_TYPE="marketplace-env = \"gcp\""
else
  readonly LICENSE_TYPE="license-key = \"${LICENSE_KEY}\""
fi

sudo mv /etc/influxdb/influxdb.conf /etc/influxdb/influxdb.conf.backup
echo "# this config was generated by the instance template startup script

hostname = \"${NODE_PRIVATE_DNS}\"

[enterprise]
  ${LICENSE_TYPE}

[meta]
  # Directory where the cluster metadata is stored.
  dir = \"${INFLUX_DIR}/meta\"

[data]
  # The directory where the TSM storage engine stores TSM (read-optimized) files.
  dir = \"${INFLUX_DIR}/data\"

  # The directory where the TSM storage engine stores WAL (write-optimized) files.
  wal-dir = \"${INFLUX_DIR}/wal\"

[hinted-handoff]
  # Determines whether hinted handoff is enabled.
  #  enabled = true

  # The directory where the hinted handoff queues are stored.
  dir = \"${INFLUX_DIR}/hh\"

[http]
  # Determines whether HTTP authentication is enabled.
  auth-enabled = true
" | sudo tee -a /etc/influxdb/influxdb.conf > /dev/null

sudo mkdir "${INFLUX_DIR}/meta" "${INFLUX_DIR}/data" "${INFLUX_DIR}/wal" "${INFLUX_DIR}/hh"
sudo chown -R influxdb:influxdb "${INFLUX_DIR}"

sudo systemctl enable influxdb
sudo systemctl start influxdb

set_rtc_var_text "${DEPLOYMENT}-rtc" "internal-dns/data/${HOSTNAME}" "${NODE_PRIVATE_DNS}"
