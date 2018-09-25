


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

TOKEN=$(curl --retry 5 -s -f -H 'Metadata-Flavor: Google' http://metadata/computeMetadata/v1/instance/service-accounts/default/token | python -c "import sys, json; print json.load(sys.stdin)['access_token']")

curl -s -k -X GET -H 'Authorization: Bearer ${TOKEN}' -H 'Content-Type: application/json' -H 'X-GFE-SSL: yes' https://runtimeconfig.googleapis.com/v1beta1/projects/influxdata-dev/configs/rtc-name/variables/internal-ip-addresses

curl -s -k -X POST -d '{"name": "projects/influxdata-dev/configs/test-0-rtc/variables/internal-dns-meta/test-0-meta-node-vm-1cpm", "text": "test-0-meta-node-vm-1cpm"}' -H 'Authorization: Bearer ya29.c.EmQiBtxHK-FP1QtbZp_UQ43adKKkGvt1zfg2sv1Sjp9hISpOJx2YvfNHOJbfOptUN7IZY3QvH2-uda5YbR6PhaDEP2NRYUzOwjDwixjU-UUia5PbFp1cuC1QE4h6ddD0j-Tv71_C' -H 'Content-Type: application/json' -H 'X-GFE-SSL: yes' https://runtimeconfig.googleapis.com/v1beta1/projects/influxdata-dev/configs/test-0-rtc/variables

curl -s -k -X GET -H 'Authorization: Bearer ya29.c.EmQiBu8OVWYx53d9eJqRAJL42CvDPzug6napwBpkmpXTdyQaI_AgSbHe3gPYc1ppDtfrZorh0DH9Eo0DQFvc07bzZ5C9uMuAdEhCkRC8tuNwv1byhsPu1IpIYmpZgbIi9s-uV6Ru' -H 'Content-Type: application/json' -H 'X-GFE-SSL: yes' https://runtimeconfig.googleapis.com/v1beta1/projects/influxdata-dev/configs/test-0-rtc/variables/test-1-rtc
```

- name: {{ deployment }}-rtc-waiter
  type: runtimeconfig.v1beta1.waiter
  metadata:
    dependsOn:
      - {{ deployment }}-rtc
      - {{ deployment }}-meta-node-igm
  properties:
    parent: $(ref.{{ deployment }}-rtc.name)
    waiter: {{ deployment }}-rtc-dns-waiter
    timeout: {{ waiterTimeout }}
    success:
      cardinality:
        path: /success
        number: 1
    failure:
      cardinality:
        path: /failure
        number: 1


curl -s -k -X POST -d '{"name": "projects/influxdata-dev/configs/test-1-rtc/variables/meta-dns/test", "text": "success"}' -H 'Authorization: Bearer ya29.c.EmQiBqCX3T-hO0XQg5OR6o6LQ5jgtlpp91AnPA1qo7KocwaiQGV1wIpqDFfcfoRz_EmMfetab5UUcc0d8z5QcUIXjqEBbJpTdn_ortS4qWNPfy0Q7TGcDVIZxWnbFdlxXJENm_92' -H 'Content-Type: application/json' https://runtimeconfig.googleapis.com/v1beta1/projects/influxdata-dev/configs/test-1-rtc/variables

curl -s -k -X GET -H 'Authorization: Bearer ya29.c.EmQiBtOfGtnnOVtfKmsQcDijXO1lacw6zuDMsT9srJSlUKy5y314Hx3AQxCn3Ty_b4-PAmPBBkCMyDgsztWnyWBeii3p0KVGTw6uneo-u4Vx7aETOc60wjtWGi4S1uFxNSSnuDWm' -H 'Content-Type: application/json' -H 'X-GFE-SSL: yes' https://runtimeconfig.googleapis.com/v1beta1/projects/influxdata-dev/configs/test-0-rtc/variables | python -c 'import json,sys; o=json.load(sys.stdin); print "\n".join([v["name"] for v in o["variables"]]);' | grep projects/influxdata-dev/configs/test-0-rtc/variables/internal-dns/meta/ | sed 's|projects/influxdata-dev/configs/test-0-rtc/variables/internal-dns/meta/||' | sort

curl -s -k -X GET -H 'Authorization: Bearer ya29.c.EmQiBtOfGtnnOVtfKmsQcDijXO1lacw6zuDMsT9srJSlUKy5y314Hx3AQxCn3Ty_b4-PAmPBBkCMyDgsztWnyWBeii3p0KVGTw6uneo-u4Vx7aETOc60wjtWGi4S1uFxNSSnuDWm' -H 'Content-Type: application/json' -H 'X-GFE-SSL: yes' https://runtimeconfig.googleapis.com/v1beta1/projects/influxdata-dev/configs/test-0/variables/internal-dns/meta/test-0-meta-node-vm-ht59