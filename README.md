# google-deployment-manager-influxdb-enterprise
DM templates for InfluxDB Enterprise on GCP


## Create the image

Spin up a new instance with the latest Debian base image. (GCP will use Debian by default if the `--image` option is not specified.)

```
gcloud compute instances create influxdb-enterprise-byol --scopes https://www.googleapis.com/auth/cloud-platform
```

Download and install the InfluxDB Enterprise data and meta node packages and Telegraf.

```
wget https://dl.influxdata.com/enterprise/releases/influxdb-data_1.6.2-c1.6.2_amd64.deb
sudo dpkg -i influxdb-data_1.6.2-c1.6.2_amd64.deb
wget https://dl.influxdata.com/enterprise/releases/influxdb-meta_1.6.2-c1.6.2_amd64.deb
sudo dpkg -i influxdb-meta_1.6.2-c1.6.2_amd64.deb
wget https://dl.influxdata.com/telegraf/releases/telegraf_1.7.4-1_amd64.deb
sudo dpkg -i telegraf_1.7.4-1_amd64.deb
```

Install GCP `partner-utils` on your local machine.

```
mkdir partner-utils
cd partner-utils
curl -O https://storage.googleapis.com/c2d-install-scripts/partner-utils.tar.gz
tar -xzvf partner-utils.tar.gz
sudo python setup.py install
```

    
