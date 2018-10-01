#!/bin/sh

set -euxo pipefail

rm -f influxdb-enterprise-byol.zip
tmp="$(mktemp -d -t influxdb-enterprise-byol)/"

cp influxdb-enterprise-byol.jinja $tmp
cp influxdb-enterprise-byol.jinja.schema $tmp
cp influxdb-enterprise-byol.jinja.display $tmp
cp test_config.yaml $tmp
cp -r resources $tmp

cp ../simple/data-node.jinja $tmp
cp ../simple/data-node.jinja.schema $tmp
cp ../simple/meta-node.jinja $tmp
cp ../simple/meta-node.jinja.schema $tmp
cp ../simple/runtime-config.jinja $tmp
cp ../simple/runtime-config.jinja.schema $tmp
cp ../simple/setup-common.sh $tmp
cp ../simple/setup-meta.sh $tmp
cp ../simple/setup-data.sh $tmp
cp ../simple/password.py $tmp

zip -r -X influxdb-enterprise-byol.zip $tmp
rm -rf $tmp
