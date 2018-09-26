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

function get_access_token() {
  get_metadata_value "instance/service-accounts/default/token" \
    | awk -F\" '{ print $4 }'
}


readonly ACCESS_TOKEN="$(get_access_token)"
readonly INSTANCE_NAME="$(get_metadata_value "instance/name")"
readonly RUNTIME_CONFIG_URL="$(get_attribute_value "status-config-url")"
readonly RUNTIME_CONFIG_PATH="$(echo "${RUNTIME_CONFIG_URL}" | sed 's|https\?://[^/]\+/v1\(beta1\)\?/||')"
readonly VARIABLE_PATH="$(get_attribute_value "status-variable-path")"

readonly ACTIONBASE64="$(echo -n "${ACTION}" | base64)"
readonly PAYLOAD="$(printf '{"name": "%s", "value": "%s"}' "${RUNTIME_CONFIG_PATH}/variables/${VARIABLE_PATH}/${ACTION}/${INSTANCE_NAME}" "${ACTIONBASE64}")"
echo "Posting software startup ${ACTION} status"
curl -s \
  -X POST \
  -d "${PAYLOAD}" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  "${RUNTIME_CONFIG_URL}/variables"

# a variable of ACTION should be equal to either "success" or "failure".