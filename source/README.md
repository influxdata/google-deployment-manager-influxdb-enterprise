# Deployment Manager Templates

The temaplets available in this repository can be used to provision an InfluxDB Enterprise cluster using GCP Deployment Manager directly (not through the GCP Marketplace). 

## Create a cluster

Install the [GCP command line tools](https://cloud.google.com/sdk/) or use the [GCP cloud shell](https://cloud.google.com/shell/).

Set an environment named `LICENSE_KEY` that contains your InfluxDB Enterprise license key. Existing license keys can be found on the [InfluxData licensing portal](https://portal.influxdata.com/). Free trials are also available through the licensing portal.

Run the following command to deploy an InfluxDB Enterprise cluster:

```
LICENSE_KEY="xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx"
gcloud deployment-manager deployments create influxdb-enterprise-0 \
    --template influxdb-enterprise.jinja \
    --properties "licenseKey:'${LICENSE_KEY}'" \
    --automatic-rollback-on-error
```

gcloud deployment-manager deployments create influxdb-enterprise-0 \
    --template influxdb-enterprise.jinja \
    --automatic-rollback-on-error

## Delete a cluster

To delete the cluster, run the following command:

```
gcloud deployment-manager delete influxdb-enterprise-0
```