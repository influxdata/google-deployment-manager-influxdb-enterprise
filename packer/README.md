# InfluxDB Enterprise Image Build 

__OFFICIAL INFLUXDB DEPLOYMENT TEMPLATES AVAILABLE IN GCP MARKETPLACE (Recommend)__

**Note:** The official supported version of the InfluxDB Enterprise software deployment is available by subscribing to the GCP Marketplace on your GCP account. It is not necessary to build your own images. [InfluxDB Enterprise (Official Version)](https://console.cloud.google.com/marketplace/details/influxdata-public/influxdb-enterprise-vm?q=influxdb).

## Building images

Follow the [license compilation instructions](../licenses/README.md) in the `licenses` directory to put together an updated `licenses.tar.gz` archive, which will be added to the image.

New images can be build with [Hashicorp's
Packer](https://www.packer.io/docs/builders/amazon.html) using the templates in
this directory.

### Prerequisites to build images

Install [Packer](https://learn.hashicorp.com/tutorials/packer/getting-started-install).

Before running Packer, you will need to [install the `gcloud` CLI via the Google Cloud SDK](https://cloud.google.com/sdk/docs/quickstart).

Run the following commands to create a GCP service account with permissions scoped for building InfluxDB Enterprise images in the GCP project you wish to use and generate a `key.json` file in the current directory.

```sh
export GOOGLE_CLOUD_PROJECT=<your-gcp-project>

gcloud auth login
gcloud iam service-accounts create packer --project ${GOOGLE_CLOUD_PROJECT} --description="InfluxDB Enterprise on Marketplace Packer Service Account" --display-name="Marketplace Packer Service Account"
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} --member=serviceAccount:packer@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com --role=roles/compute.instanceAdmin.v1
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} --member=serviceAccount:packer@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com --role=roles/iam.serviceAccountUser
gcloud projects get-iam-policy ${GOOGLE_CLOUD_PROJECT} --flatten="bindings[].members" --format="value(bindings.members[])"
gcloud iam service-accounts keys create key.json --iam-account packer@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
```

### Run Packer

Finally, run Packer to build InfluxDB Enterprise images:

```sh
gcloud auth login

export GOOGLE_CLOUD_PROJECT=<your-gcp-project>
export GOOGLE_CREDENTIALS=key.json

packer build influxdb.json
```

After Packer completes the build, it will print the names of the images created.

```txt
==> Builds finished. The artifacts of successful builds are:
--> enterprise-data: A disk image was created: influxdb-enterprise-data-1-8-2-ubuntu-1611160220
--> enterprise-meta: A disk image was created: influxdb-enterprise-meta-1-8-2-ubuntu-1611160220
```

The portion of the image name after `influxdb-enterprise-data-` can be used as the sourceImageVersion property when deploying the DM templates, e.g. `1-8-2-ubuntu-1611160220`.
