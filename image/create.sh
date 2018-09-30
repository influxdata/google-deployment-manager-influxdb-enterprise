#!/bin/bash

set -euxo pipefail

INFLUXDB_ENTERPRISE_VERSION="1.6.2-c1.6.2"
TELEGRAF_VERSION="1.7.4"

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
    --boot-disk-device-name ${INFLUX_IMAGE_NAME} \
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
gcloud compute instances delete ${BASE_INSTANCE_NAME} \
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
    --disk "disk-name=${INFLUX_IMAGE_NAME}" \
    --no-user-output-enabled

sleep 60

echo "Uploading setup script and license archive."
gcloud compute scp clean.sh ${CLEAN_INSTANCE_NAME}:

echo "Running cleanup script."
gcloud compute ssh ${CLEAN_INSTANCE_NAME} --command "bash clean.sh"

echo "Deleting cleanup instance."
gcloud compute instances delete ${CLEAN_INSTANCE_NAME} \
    --project ${PROJECT} \
    --zone ${ZONE} \
    --no-user-output-enabled \
    --quiet

sleep 60

echo "Installing the GCP partner-utils. Password required"
mkdir partner-utils
cd partner-utils
curl -O https://storage.googleapis.com/c2d-install-scripts/partner-utils.tar.gz
tar -xzvf partner-utils.tar.gz
sudo python setup.py install

echo "Creating the image."
python image_creator.py --project ${PROJECT} \
    --disk ${INFLUX_IMAGE_NAME} \
    --name influxdata-debian-9-${INFLUX_IMAGE_NAME} \
    --description "InfluxData, InfluxDB Enterprise, version ${INFLUXDB_ENTERPRISE_VERSION}, based on Debian 9 (stretch), amd64 built on ${IMAGE_VERSION}" \
    --destination-project "influxdata-dev" \
    --license "influxdata-dev/influxdb-enterprise-byol"

echo "Cleaning up partner-utils."
cd ..
sudo rm -rf partner-utils
