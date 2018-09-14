# google-deployment-manager-influxdb-enterprise
DM templates for InfluxDB Enterprise on GCP

## Update templates

The following explains how to update the base image and Deployment Manager templates.

### Recompile ALL_LICENSES file

Follow the [instructions](licenses/README.md) in the `licenses` directory to put together an updated `ALL_LICENSES` file, which will be added to the base image.

## Create the base image

Spin up a new instance with the latest Debian base image. (GCP will use Debian by default if the `--image` option is not specified.)

```
gcloud compute instances create influxdb-enterprise-byol-base --scopes https://www.googleapis.com/auth/cloud-platform
```

Upload the `ALL_LICENSES` file and package with the required source code.

```
gcloud compute scp licenses/licenses.tar.gz influxdb-enterprise-byol-base:/etc/licenses/source
```

Now, download and install the InfluxDB Enterprise data and meta node packages and Telegraf. All systems will be disabled by default. Finally, upload the base config files.

```
wget https://dl.influxdata.com/enterprise/releases/influxdb-data_1.6.2-c1.6.2_amd64.deb
sudo dpkg -i influxdb-data_1.6.2-c1.6.2_amd64.deb
sudo systemctl disable influxdb

wget https://dl.influxdata.com/enterprise/releases/influxdb-meta_1.6.2-c1.6.2_amd64.deb
sudo dpkg -i influxdb-meta_1.6.2-c1.6.2_amd64.deb
sudo systemctl disable influxdb-meta

wget https://dl.influxdata.com/telegraf/releases/telegraf_1.7.4-1_amd64.deb
sudo dpkg -i telegraf_1.7.4-1_amd64.deb
sudo systemctl disable telegraf
```

Install GCP `partner-utils` on your local machine.

```
mkdir partner-utils
cd partner-utils
curl -O https://storage.googleapis.com/c2d-install-scripts/partner-utils.tar.gz
tar -xzvf partner-utils.tar.gz
sudo python setup.py install
```


