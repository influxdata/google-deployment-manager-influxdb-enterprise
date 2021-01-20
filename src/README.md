# Google Deployment Manager Templates for InfluxDB Enterpise 

__OFFICIAL INFLUXDB DEPLOYMENT TEMPLATES AVAILABLE IN GCP MARKETPLACE (Recommend)__

The templates in this repository can be used to provision an InfluxDB Enterprise cluster using GCP Deployment Manager directly (not through the GCP Marketplace). An InfluxDB Enterprise license key is required to run. [Sign up for a free two-week trial license here](https://portal.influxdata.com/users/new).

## Getting Started

Install the [GCP command line tools](https://cloud.google.com/sdk/) or use the [GCP cloud shell](https://cloud.google.com/shell/).

Set an environment named `LICENSE_KEY` that contains your InfluxDB Enterprise license key. Existing license keys can be found on the [InfluxData licensing portal](https://portal.influxdata.com/). Free trials are also available through the licensing portal.

Run the following command to deploy an InfluxDB Enterprise cluster:

```sh
LICENSE_KEY="xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx"
gcloud deployment-manager deployments create influxdb-enterprise-0 \
    --template influxdb-enterprise.jinja \
    --properties "licenseKey:'${LICENSE_KEY}',sourceImageProject:'influxdata-dev', sourceImageVersion:'1-8-2-ubuntu-1610533546'" \
    --automatic-rollback-on-error \
    --async
```

Then check the status of the deployment:

```sh
gcloud deployment-manager deployments describe influxdb-enterprise-0
```

## Delete cluster

To delete the cluster, run the following command:

```sh
gcloud deployment-manager delete influxdb-enterprise-0
```
