#!/bin/bash

set -euxo pipefail

INFLUXDB_ENTERPRISE_VERSION="1.6.4-c1.6.4"
TELEGRAF_VERSION="1.8.3"

IMAGE_VERSION="v$(date +%Y%m%d)"
PROJECT="influxdata-dev"
ZONE="us-central1-f"

BASE_INSTANCE_NAME="influx-enterprise-base-${IMAGE_VERSION}"
BASE_IMAGE_URI=$(gcloud compute images list --filter="family=( 'debian-9' )" --uri)
INFLUX_IMAGE_NAME="influxdb-enterprise-${IMAGE_VERSION}"

echo "Creating base instance: ${BASE_INSTANCE_NAME}"
gcloud compute instances create ${BASE_INSTANCE_NAME} \
    --project ${PROJECT} \
    --zone ${ZONE} \
    --machine-type "n1-standard-1" \
    --network "default" \
    --maintenance-policy "MIGRATE" \
    --scopes default \
    --image ${BASE_IMAGE_URI} \
    --boot-disk-size "10" \
    --boot-disk-type "pd-standard" \
    --no-boot-disk-auto-delete \
    --no-user-output-enabled \
    --quiet

sleep 60

echo "Uploading setup script and license archive."
gcloud compute scp ../licenses/licenses.tar.gz ${BASE_INSTANCE_NAME}:
gcloud compute scp setup.sh ${BASE_INSTANCE_NAME}:

echo "Running setup script."
gcloud compute ssh ${BASE_INSTANCE_NAME} --command "bash setup.sh ${INFLUXDB_ENTERPRISE_VERSION} ${TELEGRAF_VERSION}"
gcloud compute ssh ${BASE_INSTANCE_NAME} --command "rm setup.sh"

echo "Deleting base instance."
gcloud -q compute instances delete ${BASE_INSTANCE_NAME} \
    --project ${PROJECT} \
    --zone ${ZONE} \
    --keep-disks "boot" \
    --no-user-output-enabled

sleep 60

CLEAN_INSTANCE_NAME="influx-enterprise-clean-${IMAGE_VERSION}"

echo "Creating cleanup instance: ${CLEAN_INSTANCE_NAME}"
gcloud compute instances create ${CLEAN_INSTANCE_NAME} \
    --project ${PROJECT} \
    --zone ${ZONE} \
    --machine-type "n1-standard-1" \
    --network "default" \
    --maintenance-policy "MIGRATE" \
    --scopes default \
    --image ${BASE_IMAGE_URI} \
    --disk "name=${BASE_INSTANCE_NAME}" \
    --no-user-output-enabled

sleep 60

echo "Uploading setup script and license archive."
gcloud compute scp clean.sh ${CLEAN_INSTANCE_NAME}:

echo "Running cleanup script."
gcloud compute ssh ${CLEAN_INSTANCE_NAME} --command "bash clean.sh"

echo "Deleting cleanup instance."
gcloud -q compute instances delete ${CLEAN_INSTANCE_NAME} \
    --project ${PROJECT} \
    --zone ${ZONE} \
    --no-user-output-enabled

sleep 60

echo "Publishing image via cloud-shell."
gcloud alpha cloud-shell scp localhost:publish.sh cloudshell:
gcloud alpha cloud-shell ssh --command "bash publish.sh ${PROJECT} ${BASE_INSTANCE_NAME} ${INFLUX_IMAGE_NAME} ${INFLUXDB_ENTERPRISE_VERSION} ${IMAGE_VERSION}"
gcloud alpha cloud-shell ssh --command "rm publish.sh"
