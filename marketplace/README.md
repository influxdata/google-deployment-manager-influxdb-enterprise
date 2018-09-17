# GCP Marketplace

This directory contains all Deployment Manager templates and supporting files needed for the [InfluxDB Enterprise BYOL listing on the GCP Marketplace]().

## Overview

The GCP Marketplace listing for InfluxDB Enterprise BYOL contains the following files.

```
influxdb-enterprise-byol.jinja
influxdb-enterprise-byol.jinja.schema
influxdb-enterprise-byol.jinja.display
test_config.yaml
resources/us-en/logo.png
```

The support files for this deployment include:

```
# DM resource files

# startup scripts included in DM template
utils.sh
meta-setup.sh
meta-master-setup.sh
data-setup.sh
```

# Using Autogen (not in use)

[Deployment Manager `autogen`](https://github.com/GoogleCloudPlatform/deploymentmanager-autogen) is a useful tool for auto-generating a complete set of deployment manager templates from a single YAML file that describes a single solution. Unfortunately, it does not yet support instance groups and some other resources used in the BYOL listing and is therefore not used.

The command to run autogen is shown below in case the tool is extended to cover the missing resource types.

```
autogen --input_type YAML --single_input autogen.yaml --output_type PACKAGE --output solution_folder
```
