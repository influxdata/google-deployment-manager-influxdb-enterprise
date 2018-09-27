# Autogen tooling (not currently used)

[Deployment Manager's `autogen` tool](https://github.com/GoogleCloudPlatform/deploymentmanager-autogen) is useful for auto-generating a complete set of deployment manager templates from a single YAML file that describes a single solution. `autogen` does not yet support instance groups which are required for hooking up a load balancer to a cluster. Therefore, it is only used to generate the base files used in the InfluxDB Enterprise GCP Marketplace listings. 

Here is the command to run `autogen`. The generated files are written to the `solution_folder`.

```
autogen --input_type YAML --single_input autogen.yaml --output_type PACKAGE --output solution_folder
```

## Future plans

If support for instance templates and instance group managers is added to `autogen`, it would be worth extending this autogen template to become the source of all Deployment Manager templates.
