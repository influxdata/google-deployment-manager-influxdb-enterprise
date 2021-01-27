#!/bin/sh

set -euxo pipefail

rm -f influxdb-enterprise.zip
tmp="$(mktemp -d -t influxdb-enterprise-XXXXXX)/"
cwd=$PWD

cp ./src/influxdb-enterprise.jinja $tmp
cp ./src/influxdb-enterprise.jinja.schema $tmp
cp ./src/influxdb-enterprise.jinja.display $tmp
cp ./src/c2d_deployment_configuration.json $tmp
cp ./src/test_config.yaml $tmp
# cp -r resources $tmp

cp ../src/data-node.jinja $tmp
cp ../src/data-node.jinja.schema $tmp
cp ../src/meta-node.jinja $tmp
cp ../src/meta-node.jinja.schema $tmp
cp ../src/runtime-config.jinja $tmp
cp ../src/runtime-config.jinja.schema $tmp
cp ../src/network.jinja $tmp
cp ../src/network.jinja.schema $tmp
cp ../src/setup-common.sh $tmp
cp ../src/setup-meta.sh $tmp
cp ../src/setup-data.sh $tmp
cp ../src/password.py $tmp

cd $tmp
zip -r -X $cwd/influxdb-enterprise.zip ./*
cd -
rm -rf $tmp
