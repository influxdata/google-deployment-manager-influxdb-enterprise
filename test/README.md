


```
gcloud deployment-manager deployments create influx-test \
    --config parameters.simple.yaml \
    --properties "LICENSE_KEY:'${LICENSE_KEY}'" \
    --preview \
    --automatic-rollback-on-error
```

Rerun startup script
```
sudo google_metadata_script_runner --script-type startup
```

See startup script logs
```
sudo journalctl -u google-startup-scripts.service
```


Test setting a runtimeconfig variable
```
TOKEN=$(curl --retry 5 -s -f -H 'Metadata-Flavor: Google' http://metadata/computeMetadata/v1/instance/service-accounts/default/token | awk -F\" '{ print $4 }')

curl -s -k -X GET -H 'Authorization: Bearer ${TOKEN}' -H 'Content-Type: application/json' -H 'X-GFE-SSL: yes' https://runtimeconfig.googleapis.com/v1beta1/projects/influxdata-dev/configs/rtc-name/variables/internal-ip-addresses
```