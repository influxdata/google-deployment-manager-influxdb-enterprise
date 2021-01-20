# google-deployment-manager-influxdb-enterprise

This repository contains all templates necessary to deploy InfluxDB Enterprise
virtual machines in Google Cloud Platform (GCP) via Deployment Manager (DM)
templates.

This repository contains:

- Google Deployment Manager templates in the [`src/` directory](src/) can be
  used to directly provision an InfluxDB Enterprise cluster.
- Packer templates in the [`packer/` directory](#build-custom-images) to build
  custom InfluxDB Enterprise images on Google Cloud Platform.

**Note:** [InfluxDB Enterprise (Official
Version)](https://console.cloud.google.com/marketplace/details/influxdata-public/influxdb-enterprise-vm?q=influxdb)
is available through the Google Cloud Marketplace. This repository contains the
resources used in the marketplace offer for reference and use by customers with
InfluxDB Enterprise license key purchased outside the GCP Marketplace ([sign up
for a free two-week trial](https://portal.influxdata.com/users/gcp)).

## Getting started

Install the [GCP command line tools](https://cloud.google.com/sdk/) or use the
[GCP cloud shell](https://cloud.google.com/shell/). Set the active configuration
to the project and zone where you would like the cluster to be deployed.

Purchase the [InfluxDB Enterprise (Official
Version)](https://console.cloud.google.com/marketplace/details/influxdata-public/influxdb-enterprise-vm?q=influxdb)
offer from Google Cloud Marketplace.

An InfluxDB Enterprise cluster can be deployed directly from the GCP console UI
after signing up for the offer. Alternatively, an InfluxDB Enterprise cluster
can be deployed using the templates in this repository using the following
command.

```sh
gcloud deployment-manager deployments create influxdb-enterprise-0 \
    --template src/influxdb-enterprise.jinja \
    --automatic-rollback-on-error
```

Once the cluster is deployed successfully, read more in the documentation on
[how to access and use the
cluster](https://docs.influxdata.com/enterprise_influxdb/v1.8/install-and-deploy/deploying/google-cloud-platform/#access-the-cluster).

## Custom deployment

The configuration in the repository can also be used to deploy an InfluxDB
Enterprise cluster in Google Cloud Platform outside the GCP Marketplace. This
requires three steps:

1. Acquire an InfluxDB Enterprise license. ([Sign up for a free two-week trial
   license](https://portal.influxdata.com/users/new))
2. Build custom InfluxDB Enterprise images in your GCP account.
3. Deploying the DM templates using the custom images.

### Deploy cluster from DM templates

Install the [GCP command line tools](https://cloud.google.com/sdk/) or use the
[GCP cloud shell](https://cloud.google.com/shell/).

Set an environment named `LICENSE_KEY` that contains your InfluxDB Enterprise
license key. Existing license keys can be found on the [InfluxData licensing
portal](https://portal.influxdata.com/). Free trials are also available through
the licensing portal.

Run the following command to deploy an InfluxDB Enterprise cluster with the
images available through [InfluxDB
Enterprise](https://console.cloud.google.com/marketplace/details/influxdata-public/influxdb-enterprise-vm?q=influxdb)
on Google Cloud Marketplace. To generate your own source images, follow the
[instructions to build images](#building-images).

```sh
export LICENSE_KEY="xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx"

gcloud deployment-manager deployments create influxdb-enterprise-0 \
    --template src/influxdb-enterprise.jinja \
    --properties "licenseKey:'${LICENSE_KEY}',sourceImageProject:'influxdata-public',sourceImageVersion:'1-8-2-ubuntu-1611160220'" \
    --automatic-rollback-on-error
```

To check the status of the deployment:

```sh
gcloud deployment-manager deployments describe influxdb-enterprise-0
```

### Delete cluster

To delete the cluster, run the following command:

```sh
gcloud deployment-manager delete influxdb-enterprise-0
```

## Images

The InfluxDB Enterprise images are based on Debian source images.

### Building images

New images can be build with [Hashicorp's
Packer](https://www.packer.io/docs/builders/amazon.html) using the templates in
the `packer/` directory.

#### Prerequisites

Install
[Packer](https://learn.hashicorp.com/tutorials/packer/getting-started-install).

Before running Packer, you will need to [install the `gcloud` CLI via the Google
Cloud SDK](https://cloud.google.com/sdk/docs/quickstart).

Run the following commands to create a GCP service account with permissions
scoped for building InfluxDB Enterprise images in the GCP project you wish to
use and generate a `key.json` file in the current directory.

```sh
cd packer
export GOOGLE_CLOUD_PROJECT="your-gcp-project"

gcloud auth login
gcloud iam service-accounts create packer --project ${GOOGLE_CLOUD_PROJECT} --description="InfluxDB Enterprise on Marketplace Packer Service Account" --display-name="Marketplace Packer Service Account"
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} --member=serviceAccount:packer@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com --role=roles/compute.instanceAdmin.v1
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} --member=serviceAccount:packer@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com --role=roles/iam.serviceAccountUser
gcloud projects get-iam-policy ${GOOGLE_CLOUD_PROJECT} --flatten="bindings[].members" --format="value(bindings.members[])"
gcloud iam service-accounts keys create key.json --iam-account packer@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
```

#### Run Packer

Finally, run Packer to build InfluxDB Enterprise images:

```sh
cd packer
gcloud auth login

export GOOGLE_CLOUD_PROJECT="your-gcp-project"
export GOOGLE_CREDENTIALS=key.json

packer build influxdb.json
```

After Packer completes the build, it will print the names of the images created.

```txt
==> Builds finished. The artifacts of successful builds are:
--> enterprise-data: A disk image was created: influxdb-enterprise-data-1-8-2-ubuntu-1611160220
--> enterprise-meta: A disk image was created: influxdb-enterprise-meta-1-8-2-ubuntu-1611160220
```

The portion of the image name after `influxdb-enterprise-data-` can be used as
the sourceImageVersion property when deploying the DM templates, e.g.
`1-8-2-ubuntu-1611160220`.
