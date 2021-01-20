# Google Cloud Marketplace Publishing Instructions

This doc describes how to publish new images to the [InfluxDB Enterprise
(Official
Version)](https://console.cloud.google.com/marketplace/details/influxdata-public/influxdb-enterprise-vm?q=influxdb)
solution on Google Cloud Marketplace.

## Overview

This directory contains a listing of the deployment template files needed for
packaging a new InfluxDB Enterprise deployment listing for the GCP Marketplace.

The GCP Marketplace manager template for a InfluxDB Enterprise deplyment
contains the following files.

```sh
./src/influxdb-enterprise.jinja
./src/influxdb-enterprise.jinja.schema
./src/influxdb-enterprise.jinja.display
./src/test_config.yaml
./resources/us-en/logo.png
```

The GCP Marketplace  deplyment also requires the following template files from
the `src` directory:

```sh
../simple/data-node.jinja $tmp
../simple/data-node.jinja.schema $tmp
../simple/meta-node.jinja $tmp
../simple/meta-node.jinja.schema $tmp 
../simple/runtime-config.jinja $tmp
../simple/runtime-config.jinja.schema $tmp
../simple/network.jinja $tmp
../simple/network.jinja.schema $tmp
../simple/setup-common.sh $tmp
../simple/setup-meta.sh $tmp
../simple/setup-data.sh $tmp
../simple/password.py $tmp
```

## Create Deployment Package

Once all deployment manager templates are updated for a release, create a new
deployment package by running the `package.sh` script in this directory. It will
create a file called `influxdb-enterprise.zip`, which will be uploaded in the
following section.

## Make images public

To publish a new image on GCP Marketplace, the images need to be made public
with the following command.

```sh
gcloud compute images add-iam-policy-binding influxdb-enterprise-data-1-8-2-ubuntu-1611160220 --member=allAuthenticatedUsers --role=roles/compute.imageUser
gcloud compute images add-iam-policy-binding influxdb-enterprise-meta-1-8-2-ubuntu-1611160220 --member=allAuthenticatedUsers --role=roles/compute.imageUser
```
