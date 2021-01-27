# Google Cloud Marketplace Publishing Instructions

This doc describes how to publish new images to the [InfluxDB Enterprise
(Official
Version)](https://console.cloud.google.com/marketplace/details/influxdata-public/influxdb-enterprise-vm?q=influxdb)
solution on Google Cloud Marketplace.

## Overview

Steps to update InfluxDB Enterprise offer on GCP Marketplace.

1. Update license list
1. Build new images
1. Update the DM templates
1. Test a deployment
1. Make images public
1. Create the deployment package
1. Test and submit the update

### Prerequisites

- [Packer](https://learn.hashicorp.com/tutorials/packer/getting-started-install).
- [`gcloud` CLI tool via the Google Cloud SDK](https://cloud.google.com/sdk/docs/quickstart).

### Update license list

GCP Marketplace requires all images to contain an up-to-date list of the
licenses and licenses of depenedencies of all open source software installed on
the image.

All directions and scripts needed to compile the license list can be found in
the [/licenses directory](/licenses). Packer will automatically copy the license
list at `/licenses/licenses.tar.gz` into the image at build time.

### Build new images

Everything needed to build new images is in the [`/packer` directory](/packer).

Public images are built in the `influxdata-public` project. Development and
testing should use the `influxdata-dev` project.

Run the following commands to generate a Google service account key for Packer in the current directory and
then build the images in the GCP project specified:

```sh
# Replace "your-gcp-project" with the name of the Google Cloud project
export GOOGLE_CLOUD_PROJECT="influxdata-dev"

# File where the Google Service Account key will be stored
export GOOGLE_SERVICE_ACCOUNT_KEY="key.dev.json"

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

### Update DM templates

All Google Deployment Manager templates for a standalone cluster with a license
key are in the [`/src` directory](/src).

The GCP Marketplace templates in the [`/marketplace/src`
directory](/marketplace/src) use the common templates from [`/src`](/src).

To update the templates, update all instances of `sourceImageVersion` with the
new image names, particularly these files.

```sh
marketplace/src/c2d_deployment_configuration.json
marketplace/src/influxdb-enterprise.jinja
src/influxdb-enterprise.jinja.schema
```

### Test a deployment

The following command will create a deployment with the newly built images.

```sh
# Replace "your-gcp-project" with the name of the Google Cloud project
export GOOGLE_CLOUD_PROJECT="influxdata-dev"

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

Make sure the InfluxDB Enterprise cluster deploys correctly and there are no
errors.

### Make images public

To publish new images on GCP Marketplace, the images need to be made public with
the following command. Only images in the `influxdata-public` project that will
be submitted for the GCP Marketplace offer should be made public.

```sh
gcloud compute images add-iam-policy-binding influxdb-enterprise-data-1-8-2-ubuntu-1611160220 --member=allAuthenticatedUsers --role=roles/compute.imageUser
gcloud compute images add-iam-policy-binding influxdb-enterprise-meta-1-8-2-ubuntu-1611160220 --member=allAuthenticatedUsers --role=roles/compute.imageUser
```

### Create Deployment Package

Once all deployment manager templates are updated for a release, create a new
deployment package by running the `package.sh` script in this directory. This
will create a file called `influxdb-enterprise.zip`.

On the [GCP Marketplace solution
draft](https://console.cloud.google.com/partner/editor/influxdata-public/influxdb-enterprise-vm?project=influxdata-public),
upload the file in the deployment package section. Any errors in the template
will be reported when saving the draft.

### Test and submit the update

Before submitting the update, check the draft by deploying the draft offer.
Remember to switch to the `influxdata-dev` project when viewing the draft offer
as the cluster will not deploy in the `influxdata-public` project.

Once everything looks good, submit the update.
