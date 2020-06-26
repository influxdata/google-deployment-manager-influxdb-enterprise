# Package Templates

__OFFICIAL INFLUXDB DEPLOYMENT TEMPLATES AVAILABLE IN GCP MARKETPLACE (Recommend)__

**Note:** The official supported version of the InfluxDB Enterprise software deployment is available by subscribing to the GCP Marketplace on your GCP account. It is not necessary to package your own templates. [InfluxDB Enterprise (Official Version)](https://console.cloud.google.com/marketplace/details/influxdata-public/influxdb-enterprise-vm?q=influxdb).

## Overview

This directory contains a listing of the deployment template files needed for packaging a new InfluxDB Enterprise deployment listing
for the GCP Marketplace. 

The GCP Marketplace manager template for a InfluxDB Enterprise deplyment contains the following files.

```
./billing/influxdb-enterprise.jinja
./billing/influxdb-enterprise.jinja.schema
./billing/influxdb-enterprise.jinja.display
./billing/test_config.yaml
./resources/us-en/logo.png
```

 The GCP Marketplace  deplyment also requires the follwoing template files from the `source` directory:

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

Once all deployment manager templates are updated for a release, create a new deployment package by running the `package.sh` script in this directory. It will create a file called `influxdb-enterprise.zip`, which will be uploaded in the following section.
