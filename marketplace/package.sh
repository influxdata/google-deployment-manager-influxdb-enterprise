#!/bin/sh

set -euxo pipefail

rm -f influxdb-enterprise-byol.zip
tmp="$(mktemp -d -t influxdb-enterprise-XXXXXX)/"
cwd=$PWD

cp "$1"/influxdb-enterprise-${2}.jinja $tmp
cp "$1"/influxdb-enterprise-${2}.jinja.schema $tmp
cp "$1"/influxdb-enterprise-${2}.jinja.display $tmp
cp "$1"/c2d_deployment_configuration.json $tmp
cp "$1"/test_config.yaml $tmp
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
