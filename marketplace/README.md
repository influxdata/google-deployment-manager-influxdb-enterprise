# Publishing an image

__PLEASE USE OFFICIAL DEPLOYMENT TEMPLATES AVAILABLE IN GCP MARKETPLACE!__

**Note:** Official images are available by subscribing to a GCP Marketplace InfluxDB Enterprise product on your GCP account so it is not necessary to publish your
own images. [InfluxDB Enterprise (Official Version)](https://console.cloud.google.com/marketplace/details/influxdata-public/influxdb-enterprise-vm?q=influxdb).

## Overview

This directory contains the deployment templates and supporting files needed for publishing a new InfluxDB Enterprise BYOL deployment listing
on the GCP Marketplace. 

Publishing deployment listings is only necessary if you would like to deploy an InfluxDB Enterprise cluster using a different a different version or configration from the supported deployment templates, which requires an InfluxDB Enterprise license.

The GCP Marketplace manager template for a InfluxDB Enterprise billing deplyment contains the following files.

```
./billing/influxdb-enterprise-byol.jinja
./billing/influxdb-enterprise-byol.jinja.schema
./billing/influxdb-enterprise-byol.jinja.display
./billing/test_config.yaml
./resources/us-en/logo.png
```

 The GCP Marketplace  deplyment also requires the follwoing template files from the `simple` directory:

```
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

Once all deployment manager templates are updated for a release, create a new deployment package by running the `package.sh` script in this directory. It will create a file called `influxdb-enterprise-byol.zip`, which will be uploaded in the following section.
