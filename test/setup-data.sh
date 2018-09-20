###
### Mount disk
###

# confirm disk is not already mounted
if [ -d "/mnt/influxdb" ]; then
  echo "InfluxDB Enterprise volume already exists. Exiting now."
  exit
fi

# mount influxdb disk
format_and_mount_disk "influxdb" "/mnt/influxdb"

###
### Set IP address as runtime config
###

# confirm disk does not already have data
if [ -d "/mnt/influxdb/data" ]; then
  echo "InfluxDB Enterprise data dir already exists. Exiting immediately."
  exit
elif [ -d "/mnt/influxdb/meta" ]; then
  echo "InfluxDB Enterprise meta dir already exists. Exiting immediately."
  exit
fi

INTERNAL_IP=$(get_internal_ip)
echo "${INTERNAL_IP}"

HOSTNAME=$(get_hostname)
echo "${HOSTNAME}"

RTC_NAME=$(get_attributes_value "rtc-name")
echo "${RTC_NAME}"

DEPLOYMENT=$(get_attributes_value "deployment")
echo "${DEPLOYMENT}"

set_rtc_var_text "RTC_NAME" "${HOSTNAME}/internal-ip-address" "${INTERNAL_IP}"

read_rtc_var_text "RTC_NAME" "${HOSTNAME}/internal-ip-address"
