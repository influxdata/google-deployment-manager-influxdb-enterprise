#!/usr/bin/env bash

set -euxo pipefail

readonly project="${1}"
readonly key_filename="${2}"

gcloud iam service-accounts create packer-influxdb-enterprise --project "${project}" --description="Packer Service Account for building InfluxDB Enterprise images" --display-name="Packer Service Account InfluxDB Enterprise"
gcloud projects add-iam-policy-binding "${project}" --member="serviceAccount:packer-influxdb-enterprise@${project}.iam.gserviceaccount.com --role=roles/compute.instanceAdmin.v1"
gcloud projects add-iam-policy-binding "${project}" --member="serviceAccount:packer-influxdb-enterprise@${project}.iam.gserviceaccount.com" --role=roles/iam.serviceAccountUser
gcloud projects get-iam-policy "${project}" --flatten="bindings[].members" --format="value(bindings.members[])"
gcloud iam service-accounts keys create "${key_filename}" --iam-account "packer-influxdb-enterprise@${project}.iam.gserviceaccount.com"
