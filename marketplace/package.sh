#!/bin/sh

rm influxdb-enterprise-byol.zip
tmp="$(mktemp -t influxdb-enterprise-byol)"

cp influxdb-enterprise-byol.jinja $tmp/influxdb-enterprise.py
cp influxdb-enterprise-byol.jinja.schema $tmp
cp influxdb-enterprise-byol.jinja.display $tmp
cp test_config.yaml $tmp
cp -r resources $tmp
cp c2d_deployment_configuration.json $tmp

cp data_group.jinja $tmp
cp data_group.jinja.schema $tmp
cp meta_group.jinja $tmp
cp meta_group.jinja.schema $tmp

cp deployment.py $tmp
cp cluster.py $tmp
cp group.py $tmp
cp server_setup.sh $tmp

zip -r -X influxdb-enterprise-byol.zip $tmp
rm -rf $tmp
