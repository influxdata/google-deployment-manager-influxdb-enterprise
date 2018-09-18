


```
gcloud deployment-manager deployments create influx-test \
    --config parameters.simple.yaml \
    --properties "LICENSE_KEY:'${LICENSE_KEY}'" \
    --preview \
    --automatic-rollback-on-error
```