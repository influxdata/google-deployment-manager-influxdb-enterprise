#!/bin/bash

# Volume mount operations
function format_and_mount_disk() {
  local -r disk_name="$1"
  local -r mount_dir="$2"
  local -r filesystem="${3:-ext4}"

  # Validate the filesystem variable.
  # Currently supported: ext4 and xfs.
  if [[ ! ("${filesystem}" == "ext4" || "${filesystem}" == "xfs") ]]; then
    echo "Error: unexpected filesystem: ${filesystem}. Expected ext4 or xfs."
    exit 1
  fi

  # Translate the disk's name to filesystem path.
  local -r disk_path="/dev/disk/by-id/google-${disk_name}"

  # Create mount directory.
  mkdir -p "${mount_dir}"
  chmod 0755 "${mount_dir}"

  case "${filesystem}" in
    ext4)
      echo "Format disk: mkfs.ext4 '${disk_path}'"
      mkfs.ext4 "${disk_path}"
    ;;
    xfs)
      # Formatting the disk with mkfs.xfs requires
      # the xfsprogs package to be installed.
      echo "Format disk: mkfs.xfs '${disk_path}'"
      mkfs.xfs "${disk_path}"
    ;;
  esac

  # Try to mount disk after formatted it.
  echo "Mount disk '${disk_name}'"
  mount -o discard,defaults -t "${filesystem}" "${disk_path}" "${mount_dir}"

  # Add an entry to /etc/fstab to mount the disk on restart.
  echo "${disk_path} ${mount_dir} ${filesystem} discard,defaults 0 2" \
    >> /etc/fstab
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

function get_project_id() {
  get_metadata_value "project/project-id"
}

# IP operations
function get_internal_ip() {
  get_metadata_value "instance/network-interfaces/0/ip"
}

function get_external_ip() {
  get_metadata_value "instance/network-interfaces/0/access-configs/0/external-ip"
}

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

function filter_rtc_var() {
  local -r project_id="$(get_project_id)"

  local -r rtc_name="$1"
  local -r filter="projects/${project_id}/configs/${rtc_name}/variables/$2"
  local -r full_var_names=$(read_rtc_var "${rtc_name}" "" |
    python -c 'import json,sys; o=json.load(sys.stdin); print "\n".join([v["name"] for v in o["variables"]]);')
  
  printf '%b\n' "${full_var_names}" | grep "${filter}" | sed "s|${filter}||" | sort
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

# Waiters
function read_rtc_waiter() {
  local -r project_id="$(get_project_id)"
  local -r access_token="$(get_access_token)"

  local -r rtc_name="$1"
  local -r waiter_name="$2"

  curl -s -k -X GET \
    -H "Authorization: Bearer ${access_token}" \
    -H "Content-Type: application/json" \
    -H "X-GFE-SSL: yes" \
    "https://runtimeconfig.googleapis.com/v1beta1/projects/${project_id}/configs/${rtc_name}/waiters/${waiter_name}"
}

function get_rtc_waiter_status() {
  local -r rtc_name="$1"
  local -r waiter_name="$2"
  local -r response="$(read_rtc_waiter "${rtc_name}" "${waiter_name}")"

  if [[ "$(echo "${response}" | grep -c "\"done\": true")" -eq 1 ]]; then
    if [[ "$(echo "${response}" | grep -c "\"error\":")" -eq 1 ]]; then
      echo "FAILED"
    else
      echo "SUCCESS"
    fi
  else
    echo "UNKNOWN"
  fi
}

function get_current_time_in_sec() {
  date +%s
}

function wait_for_rtc_waiter_success() {
  local -r rtc_name="$1"
  local -r waiter_name="$2"
  local -r timeout_sec="${3:-600}"

  local -r timeout_time_sec=$(($(get_current_time_in_sec) + "${timeout_sec}"))

  echo "Waiting for waiter '${waiter_name}' with timeout of ${timeout_sec}s..."

  local status="$(get_rtc_waiter_status "${rtc_name}" "${waiter_name}")"
  while [[ "${status}" != "SUCCESS" ]] \
        && [[ $(get_current_time_in_sec) -lt ${timeout_time_sec} ]]; do
    if [[ "${status}" == "FAIL" ]]; then
      echo "Waiter '${waiter_name}' failed"
      return 1
    else
      echo "Waiter '${waiter_name}' not finished yet - sleeping 3s..."
      sleep 3
      local status="$(get_rtc_waiter_status "${rtc_name}" "${waiter_name}")"
    fi
  done
  echo "Waiter '${waiter_name}' succeeded"
}
