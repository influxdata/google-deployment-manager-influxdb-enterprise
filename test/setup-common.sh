#!/bin/bash

set -euxo pipefail

# Runtime config variable operations

function read_rtc_var() {
  local -r project_id="$(get_project_id)"
  local -r access_token="$(get_access_token)"

  local -r rtc_name="$1"
  local -r var_name="$2"

  curl -s -k -X GET \
    -H "Authorization: Bearer ${access_token}" \
    -H "Content-Type: application/json" \
    -H "X-GFE-SSL: yes" \
    "https://runtimeconfig.googleapis.com/v1beta1/projects/${project_id}/configs/${rtc_name}/variables/${var_name}"
}

function get_rtc_var_text() {
  local -r rtc_name="$1"
  local -r var_name="$2"
  read_rtc_var "${rtc_name}" "${var_name}" |
    python -c 'import json,sys; o=json.load(sys.stdin); print o["text"];'
}

function set_rtc_var_text() {
  local -r project_id="$(get_project_id)"
  local -r access_token="$(get_access_token)"

  local -r rtc_name="$1"
  local -r var_name="$2"
  local -r var_text="$3"

  local -r payload="$(printf '{"name": "%s", "text": "%s"}' \
    "projects/${project_id}/configs/${rtc_name}/variables/${var_name}" \
    "${var_text}")"

  curl -s -k -X POST \
    -d "${payload}" \
    -H "Authorization: Bearer ${access_token}" \
    -H "Content-Type: application/json" \
    -H "X-GFE-SSL: yes" \
    "https://runtimeconfig.googleapis.com/v1beta1/projects/${project_id}/configs/${rtc_name}/variables"
}

# Metadata operations

function get_metadata_value() {
  curl --retry 5 \
    -s \
    -f \
    -H "Metadata-Flavor: Google" \
    "http://metadata/computeMetadata/v1/$1"
}

function get_attribute_value() {
  get_metadata_value "instance/attributes/$1"
}

function get_hostname() {
  get_metadata_value "instance/hostname"
}

function get_access_token() {
  get_metadata_value "instance/service-accounts/default/token" \
    | awk -F\" '{ print $4 }'
}

# IP operations

function get_internal_ip() {
  get_metadata_value "instance/network-interfaces/0/ip"
}

echo get_internal_ip()
echo get_hostname()

# switch to checking data directory?
if [ -d "/etc/systemd/system/influxd.service" ]; then
  echo "InfluxDB Enterprise is already initialized. Exiting immediately."
  exit
elif [ -d "/etc/systemd/system/influxd-meta.service" ]; then
  echo "InfluxDB Enterprise is already initialized. Exiting immediately."
  exit
fi
