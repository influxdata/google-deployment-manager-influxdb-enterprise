# InfluxDB Enterprise BYOL Image 

__PLEASE RECOMPILE LICENSE INFO BEFORE CREATING A NEW IMAGE!!__

Follow the [license compilation instructions](licenses/README.md) in the `licenses` directory to put together an updated `licenses.tar.gz` archive, which will be added to the image.

## Automated image creation script

The `create.sh` script will automatically create the disk needed for the image and upload it to the GCP Marketplace solution.

Remember to update the following variables in `create.sh` before running the script:

```
INFLUXDB_ENTERPRISE_VERSION
TELEGRAF_VERSION
```

## Manual image creation

The following steps explain all the steps to create an image. Use these steps if the image creation script fails for some reason.

### Create the base image

Spin up a new instance with the latest Debian base image. (GCP will use Debian by default if the `--image` option is not specified.)

```
# find the latest Debian 9 base image
# replace the --image option in the next 
gcloud compute images list --filter="family=( 'debian-9' )" --uri

IMAGE_VERSION=v20180916
gcloud compute instances create influxdb-enterprise-byol-base \
    --project "influxdata-dev" \
    --zone "us-central1-f" \
    --machine-type "n1-standard-8" \
    --network "default" \
    --maintenance-policy "MIGRATE" \
    --scopes default="https://www.googleapis.com/auth/cloud-platform" \
    --image "https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/debian-9-stretch-v20180911" \
    --boot-disk-size "10" \
    --boot-disk-type "pd-ssd" \
    --boot-disk-device-name influxdb-enterprise-${IMAGE_VERSION} \
    --no-boot-disk-auto-delete \
    --scopes https://www.googleapis.com/auth/cloud-platform
# Note: `project` should be switched to `"influxdata-public"` and `scopes` should probably be set to `"storage-rw"`. The image should be the latest stable Debain image (`gcloud compute images list`).
```

Upload the `ALL_LICENSES` file and package with the required source code and SSH into the instance.

```
gcloud compute scp licenses/licenses.tar.gz influxdb-enterprise-byol-base:
gcloud compute ssh influxdb-enterprise-byol-base
```

Once SSH'd into the instance, finish installing the license data. Then, download and install the InfluxDB Enterprise data and meta node packages and Telegraf package. All systems will be disabled by default. Finally, upload the base config files.

```
# on the influxdb-enterprise-byol-base instance

# licenses are now available at /home/gunnar/licenses
mkdir licenses
tar xvzf licenses.tar.gz --directory licenses/
rm licenses.tar.gz

wget https://dl.influxdata.com/enterprise/releases/influxdb-data_1.6.2-c1.6.2_amd64.deb
sudo dpkg -i influxdb-data_1.6.2-c1.6.2_amd64.deb
sudo systemctl disable influxdb
rm influxdb-data_1.6.2-c1.6.2_amd64.deb

wget https://dl.influxdata.com/enterprise/releases/influxdb-meta_1.6.2-c1.6.2_amd64.deb
sudo dpkg -i influxdb-meta_1.6.2-c1.6.2_amd64.deb
sudo systemctl disable influxdb-meta
rm influxdb-meta_1.6.2-c1.6.2_amd64.deb

wget https://dl.influxdata.com/telegraf/releases/telegraf_1.7.4-1_amd64.deb
sudo dpkg -i telegraf_1.7.4-1_amd64.deb
sudo systemctl disable telegraf
telegraf_1.7.4-1_amd64.deb

telegraf --input-filter cpu:mem:diskio config > telegraf.conf
sudo mv telegraf.conf /etc/telegraf/telegraf.conf
rm telegraf.conf
```

Exit the VM and delete it to get the boot disk.

```
gcloud compute instances delete influxdb-enterprise-byol-base \
    --project "influxdata-dev" \
    --zone "us-central1-f" \
    --keep-disks "boot"
# Notes: `project` should be switched to `"influxdata-public"`.
```

It may take 15 minutes or longer for the disk to be detached from the instance. The SSH key on the disk needs to be removed before it can be turned into an image. Create a new VM with the `influx-debian-9-stretch-v20180911` disk attached as an additional disk. 

```
gcloud compute instances create influxdb-enterprise-byol-cleanup \
    --project "influxdata-dev" \
    --zone "us-central1-f" \
    --machine-type "n1-standard-8" \
    --network "default" \
    --maintenance-policy "MIGRATE" \
    --image "https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/debian-9-stretch-v20180911" \
    --scopes default \
    --disk "disk-name=influxdb-enterprise-${IMAGE_VERSION}"
```

SSH into the cleanup instance, mount the disk created earlier and remove the home directory.

```
gcloud compute ssh influxdb-enterprise-byol-cleanup

# on the influxdb-enterprise-byol-cleanup instance

sudo mkdir -p /mnt/disks/influx
sudo mount -o discard,defaults /dev/sdb1 /mnt/disks/influx
sudo rm -r /mnt/disks/influx/home/gunnar
```

Now that the disk has been cleaned, delete the cleanup instance.

```
gcloud compute instances delete influxdb-enterprise-byol-cleanup \
    --project "influxdata-dev" \
    --zone "us-central1-f"
```

The resulting disk is ready to be used for creating the final solution image.

### Upload the image

To finish the image creation process, the disk needs to be used to create an image on the public InfluxData GCP project. The GCP `partner-utils` tool will be used to do from your local machine. The following commands install the tool.

```
mkdir partner-utils
cd partner-utils
curl -O https://storage.googleapis.com/c2d-install-scripts/partner-utils.tar.gz
tar -xzvf partner-utils.tar.gz
sudo python setup.py install
```

Finally, use the following command to upload the new image.

```
python image_creator.py --project "influxdata-dev" \
    --disk influxdb-enterprise-${IMAGE_VERSION} \
    --name influxdata-debian-9-influxdb-enterprise-${IMAGE_VERSION} \
    --description "InfluxData, InfluxDB Enterprise, v1.6.2-1.6.2, based on Debian 9 (stretch), amd64 built on ${IMAGE_VERSION}" \
    --destination-project "influxdata-prod" \
    --license "influxdata-prod/influxdb-enterprise-byol"
```

Alternatively, the following command will create an image without using the `partner-utils`. This will _not_ create a proper image that can be used for a GCP Marketplace listing.

```
gcloud compute images create influxdata-debian-9-influxdb-enterprise-${IMAGE_VERSION} \
  --source-disk influxdb-enterprise-${IMAGE_VERSION} \
  --source-disk-zone "us-central1-f" \
  --family "influxdb-enterprise"
```
