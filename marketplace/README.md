# GCP Marketplace

This directory contains all Deployment Manager templates and supporting files needed for the [InfluxDB Enterprise BYOL listing on the GCP Marketplace]().

## Overview

The GCP Marketplace listing for InfluxDB Enterprise BYOL contains the following files.

```
influxdb-enterprise-byol.jinja
influxdb-enterprise-byol.jinja.schema
influxdb-enterprise-byol.jinja.display
test_config.yaml
resources/us-en/logo.png
```

The support files for this deployment include:

```
# DM resource files

# startup scripts included in DM template
utils.sh
meta-setup.sh
meta-master-setup.sh
data-setup.sh
```

## Test the DM templates

```
LICENSE_KEY="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
gcloud deployment-manager deployments create my-deployment \
    --template influxdb-enterprise-byol.jinja \
    --properties "licenseKey:'${LICENSE_KEY}'" \
    --automatic-rollback-on-error
```

## Create Deployment Package

Once all deployment manager templates are updated for a release, create a new deployment package by running the `package.sh` script in this directory. It will create a file called `influxdb-enterprise-byol.zip`, which will be uploaded in the following section.

## Solution Setup

InfluxData only publishes a BYOL solution for InfluxDB Enterprise in the GCP Marketplace. The [Partner Portal](https://console.cloud.google.com/partner/solutions?project=influxdata-public).

The text used for the BYOL solution is shown below. Please update the info on the Partner Portal if any of the listing information is changed.

Also, best practice is to skip to step 7 first and upload the deployment package before double checking that all other form entries are still accurate with this readme.

#### Configure Deployment Package
Only the "Upload a package" option will work for solutions that deploy multiple VMs. Upload the `influxdb-enterprise-byol.zip` file created by earlier by running the `package.sh` script. Make sure the "Keep metadata changes from `.jinja.display`" box remains checked.
