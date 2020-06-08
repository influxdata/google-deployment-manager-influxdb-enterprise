#!/bin/sh

set -euxo pipefail

rm -f influxdb-enterprise-billing.zip
tmp="$(mktemp -d -t influxdb-enterprise-XXXXXX)/"
cwd=$PWD

cp ./billing/influxdb-enterprise.jinja $tmp
cp ./billing/influxdb-enterprise.jinja.schema $tmp
cp ./billing/influxdb-enterprise.jinja.display $tmp
cp ./billing/c2d_deployment_configuration.json $tmp
cp ./billing/test_config.yaml $tmp
cp -r resources $tmp

cp ../simple/data-node.jinja $tmp
cp ../simple/data-node.jinja.schema $tmp
cp ../simple/meta-node.jinja $tmp
cp ../simple/meta-node.jinja.schema $tmp
cp ../simple/runtime-config.jinja $tmp
cp ../simple/runtime-config.jinja.schema $tmp
cp ../simple/network.jinja $tmp
cp ../simple/network.jinja.schema $tmp
cp ../simple/setup-common.sh $tmp
cp ../simple/setup-meta.sh $tmp
cp ../simple/setup-data.sh $tmp
cp ../simple/password.py $tmp

cd $tmp
zip -r -X $cwd/influxdb-enterprise.zip ./*
cd -
rm -rf $tmp
