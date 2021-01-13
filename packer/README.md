# InfluxDB Enterprise Image Build 

__OFFICIAL INFLUXDB DEPLOYMENT TEMPLATES AVAILABLE IN GCP MARKETPLACE (Recommend)__

**Note:** The official supported version of the InfluxDB Enterprise software deployment is available by subscribing to the GCP Marketplace on your GCP account. It is not necessary to build your own images. [InfluxDB Enterprise (Official Version)](https://console.cloud.google.com/marketplace/details/influxdata-public/influxdb-enterprise-vm?q=influxdb).


## Building the images

Follow the [license compilation instructions](../licenses/README.md) in the `licenses` directory to put together an updated `licenses.tar.gz` archive, which will be added to the image.

New images can be build with [Hashicorp's
Packer](https://www.packer.io/docs/builders/amazon.html) using the templates in
this directory.

Before running Packer, you will need to install and configure the `gcloud` CLI
tool. Also, set `GOOGLE_CLOUD_PROJECT=<your-project-id>`.

Run the following command to build the images:

```sh
packer build influxdb.json
```

After Packer completes the build, it will output the name of two images.

## Automated image creation script

The `create.sh` script will automatically create the disk needed for the image and upload it to the GCP Marketplace solution.

Remember to update the following variables in `create.sh` before running the script:

```sh
INFLUXDB_ENTERPRISE_VERSION
TELEGRAF_VERSION
```

Finally, [confirm the image is public](https://cloud.google.com/marketplace/docs/partners/technical-components#make_the_image_public) by selecting the image to be published in the image list page of the GCP console in the `influxdata-public` project. Then check whether a permission for `allAuthenticatedUsers` member with the "Compute Image User" role exists.
