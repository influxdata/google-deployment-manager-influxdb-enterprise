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

### 1 - Metadata

#### Solution Name
* influxdb-enterprise-byol

#### Search Metadata
InfluxData, InfluxDB, TICK, Telegraf, Time Series, Metrics, Monitoring, Events, Tracing, IoT, NoSQL, Big Data, Database, Open Source

#### Search Keywords
* InfluxData
* InfluxDB
* Time Series
* Metrics
* Monitoring
* Database

### 2 - Solution Details

#### Name of Solution
* InfluxDB Enterprise (BYOL)

#### Tagline
Clustered version of the scalable database for metrics, events, and real-time analytics.

#### Solution Icon
[Download hi-res logo here](https://influxdata.github.io/branding/logo/downloads/)

#### Solution Description
InfluxDB Enterprise is a hardened version of InfluxDB, the open-source time series database developed by InfluxData. InfluxDB Enterprise extends the open source core with clustering for high availability and scalability, along with advanced backup, restore and access management features.

InfluxDB Enterprise is optimized for fast, high-availability storage and retrieval of time series data in fields such as operations monitoring, application metrics, Internet of Things sensor data, and real-time analytics.

#### Price Description
This template is for bring your own license (BYOL) users.  To purchase a license go <a href="https://portal.influxdata.com/users/gcp">here</a>.

#### More solution info
https://www.influxdata.com/partners/google/

#### Version
InfluxDB Enterprise version 1.6.2-c1.6.2

#### Category ID
* Databases
* Monitoring

### 3 - Company Information

_Note: that this information is not editable from the solution setup page._

#### Name of Company
InfluxData

#### Company Description
InfluxData, creator of InfluxDB, provides the leading platform for time series data from servers, sensors, and humans. Empower developers to quickly instrument, observe, automate, and scale DevOps, analytics, and IoT applications to deliver real business value.

### 4 - Test Drive

#### License Name
influxdb-enterprise-byol

#### License Purchased from Vendor
Yes (BYOL)

#### Submit Pricing
Just click this button once all fields in this section are completed.

### 5 - Test Drive

Delete the Test Drive section.

### 6 - Documentation & Support

#### Tutorials and Documentation

##### Type
Deploying InfluxDB Enterprise on Google Marketplace

##### URL
TODO(Gunnar): Update this link once public docs are posted.
https://docs.influxdata.com/enterprise_influxdb/v1.6/introduction/installation_guidelines/

##### Description
A guide to get up and running with InfluxDB Enterprise on Google Marketplace.

#### Support description
InfluxData provides support for all InfluxDB Enterprise users. Please contact your InfluxData account executive for more information on available support SLAs.

#### Support URL
http://support.influxdb.com/

#### Support ID
TODO(Gunnar): Check whether this is useful.

#### EULA URL
https://www.influxdata.com/legal/slsa/

#### More license agreements
TODO(Gunnar): Confirm there are no other license agreements needed.

### 7 - Deployment Package

#### Configure Deployment Package
Only the "Upload a package" option will work for solutions that deploy multiple VMs. Upload the `influxdb-enterprise-byol.zip` file created by earlier by running the `package.sh` script. Make sure the "Keep metadata changes from `.jinja.display`" box remains checked.
