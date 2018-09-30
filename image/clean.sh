#!/bin/bash

set -euxo pipefail

sudo mkdir -p /mnt/disks/influx
sudo mount -o discard,defaults /dev/sdb1 /mnt/disks/influx
sudo rm -r /mnt/disks/influx/home/$HOME
