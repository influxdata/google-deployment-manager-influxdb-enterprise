# InfluxDB Enterprise on Google Cloud Platform

Deploy an InfluxDB Enterprise cluster on Google Cloud Platform (GCP) Compute
Engine virtual machines with Google Deployment Manager (DM) templates.

## Getting started

There are two ways to use the templates in this repository:

- Subscribe to the [InfluxDB Enterprise offer on Google Cloud
  Marketplace](https://console.cloud.google.com/marketplace/details/influxdata-public/influxdb-enterprise-vm?q=influxdb)
  and follow the instructions to [deploy a cluster](#deploy-with-a-marketplace-subscription). All VMs
  created through GCP Marketplace are automatically licensed.
- Obtain an InfluxDB Enterprise license key and follow the instructions to
  [deploy with a license](#deploy-with-a-license-key).

## Deploy with a marketplace subscription

Subscribe to [InfluxDB Enterprise on GCP
Marketplace](https://console.cloud.google.com/marketplace/details/influxdata-public/influxdb-enterprise-vm?q=influxdb).
After subscribing, all VMs deployed using InfluxDB Enterprise images from GCP
Marketplace will automatically include a license billed to the associated GCP
account.

After subscribing to the offer, a cluster can be deployed directly from the GCP
console UI.

Alternatively, the templates in this repository can also be used to deploy an
InfluxDB Enterprise cluster from the command line using [Google Cloud
Shell](https://cloud.google.com/shell/) or the `gcloud` CLI tool from the
[Google Cloud SDK](https://cloud.google.com/sdk/), which also required cloning
this repo.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/open?git_repo=https%3A%2F%2Fgithub.com%2Finfluxdata%2Fgoogle-deployment-manager-influxdb-enterprise&page=editor)

Then run the following command to deploy a cluster:

```sh
git clone https://github.com/influxdata/google-deployment-manager-influxdb-enterprise.git
cd google-deployment-manager-influxdb-enterprise
gcloud deployment-manager deployments create influxdb-enterprise-0 \
    --template src/influxdb-enterprise.jinja \
    --automatic-rollback-on-error
```

> **Note:** `gcloud` must have an [active
> configuration](https://cloud.google.com/sdk/docs/configurations) with a
> project and compute zone name defined.

Once the cluster has successfully deployed, learn [how to access and manage
InfluxDB Enterprise on
GCP](https://docs.influxdata.com/enterprise_influxdb/v1.8/install-and-deploy/deploying/google-cloud-platform/#access-the-cluster).

## Deploy with a license key

If you have InfluxDB Enterprise license key from
[InfluxData](https://www.influxdata.com/contact-sales/) or a [trial
sign-up](https://portal.influxdata.com/users/gcp), the templates in this
repository can be used to deploy a cluster in Google Cloud Platform (no GCP
Marketplace subscription required).

### Prerequisites

- [Packer](https://learn.hashicorp.com/tutorials/packer/getting-started-install).
- [`gcloud` CLI tool via the Google Cloud SDK](https://cloud.google.com/sdk/docs/quickstart).

### Build images

You will need to build images for InfluxDB Enterprise in your GCP account using
[Hashicorp's Packer tool](https://www.packer.io/docs/builders/amazon.html) and
the templates in the `packer/` directory.

Run the following commands to generate a Google service account key for Packer and
then build the images:

```sh
# Replace "your-gcp-project" with the name of the Google Cloud project
export GOOGLE_CLOUD_PROJECT="your-gcp-project"

# File where the Google Service Account key will be stored
export GOOGLE_SERVICE_ACCOUNT_KEY="key.json"

# Ensure the Google Cloud SDK is authenticated
gcloud auth login

# Generate a Google Service Account for Packer with the
# "compute.instanceAdmin.v1" and "iam.serviceAccountUser" roles
./packer/generate-google-service-account-key.sh "${GOOGLE_CLOUD_PROJECT}" "${GOOGLE_SERVICE_ACCOUNT_KEY}"

# Build images
packer build packer/influxdb.json
```

Once the build is complete, Packer outputs the InfluxDB Enterprise image names
to the terminal and the `manifest.json` file.

```txt
==> Builds finished. The artifacts of successful builds are:
--> enterprise-data: A disk image was created: influxdb-enterprise-data-1-8-2-ubuntu-1611160220
--> enterprise-meta: A disk image was created: influxdb-enterprise-meta-1-8-2-ubuntu-1611160220
```

The portion of the image name after `influxdb-enterprise-data-` can be used as
the sourceImageVersion property when deploying the DM templates, e.g.
`1-8-2-ubuntu-1611160220`.

### Deploy a cluster

Run the following command to deploy an InfluxDB Enterprise cluster with the
images created by Packer.

```sh
# Replace "your-gcp-project" with the name of the Google Cloud project
export GOOGLE_CLOUD_PROJECT="your-gcp-project"

# Set this to your InfluxDB Enterprise license key
export INFLUXDB_ENTERPRISE_LICENSE_KEY="xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Set this to the version string obtained when building the images
export INFLUXDB_ENTERPRISE_IMAGE_VERSION="1-8-2-ubuntu-xxxxxxxx"

gcloud deployment-manager deployments create influxdb-enterprise-0 \
    --template src/influxdb-enterprise.jinja \
    --properties "licenseKey:'${INFLUXDB_ENTERPRISE_LICENSE_KEY}',\
                  sourceImageProject:'${GOOGLE_CLOUD_PROJECT}',\
                  sourceImageVersion:'${INFLUXDB_ENTERPRISE_IMAGE_NAME}'" \
    --automatic-rollback-on-error
```

### Delete the cluster

To delete the cluster, run the following command:

```sh
gcloud deployment-manager delete influxdb-enterprise-0
```
