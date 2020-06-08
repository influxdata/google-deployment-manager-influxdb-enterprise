# InfluxDB Enterprise Licensing for GCP Marketplace

**Note:** Official images are available by subscribing to a GCP Marketplace InfluxDB Enterprise product on your GCP account so it is not necessary to submit your
own licenses. [InfluxDB Enterprise (Official Version)](https://console.cloud.google.com/marketplace/details/influxdata-public/influxdb-enterprise-vm?q=influxdb).

## Links to license lists

GCP Marketplace requires every revision of a Marketplace solution to provide
up-to-date licensing information on all open source components used in the
solution. This directory explains the steps to compile this information.

The license information needs to be submitted in the [open source compliance
worksheet](https://docs.google.com/spreadsheets/d/1qkpFjAYfqadg7IVmJGEpzEPxyhjE6L8Xi5epE98OCw0/edit#gid=0)
for the InfluxDB Enterprise solution on GCP Marketplace. Images published as
part of the solution also need to include a copy of all licenses and, in some
cases, source code.

The following projects are currently included in the base image.

1. InfluxDB Enterprise
    - [Project license](https://docs.influxdata.com/enterprise_influxdb/latest/about-the-project/#commercial-license-https-www-influxdata-com-legal-slsa)
    - [Licenses of dependencies](https://raw.githubusercontent.com/influxdata/docs.influxdata.com/master/content/enterprise_influxdb/v1.7/about-the-project/_index.md)
2. InfluxDB OSS (main root dependency of InfluxDB Enterprise)
    - [Project license](https://raw.githubusercontent.com/influxdata/influxdb/v1.6.2/LICENSE)
    - [Licenses of dependencies](https://raw.githubusercontent.com/influxdata/influxdb/v1.6.2/LICENSE_OF_DEPENDENCIES.md)
3. Telegraf
    - [Project license](https://raw.githubusercontent.com/influxdata/telegraf/1.7.4/LICENSE)
    - [License of Dependencies](https://raw.githubusercontent.com/influxdata/telegraf/1.7.4/docs/LICENSE_OF_DEPENDENCIES.md)

Grafana is also installed through the GCP package repository mirror, therefore Grafana licenses do not need to be included in this list.

## Compile licenses list

Follow these steps to compile the archive of license info to be included in the
image.

1. Update the `licenses.csv` file with a list of licenses for all projects. The
    list should be in CSV format with the following columns:
        ```license short name, library name, link to license file```
    Comments on a new line starting with a `#` and new lines themselves will
    be ignored. Use the license short names defined in the
    [license mapping section below](#license-mapping)
2. If any libraries do not have a license file or are not hosted on Github the
    script will not work correctly. Those license text for those dependencies
    will need to be manually added to the `./manual` directory directory with the
    following file name format:
        ```./manual/{license-short-name}/{library-name}```
    If source is required, a zip file of the library should be put in the
    following directory:
        ```./manual/{license-short-name}/source/{library-name}.zip```
3. Run the `compile.sh` script to create a `licenses.tar.gz` archive.

The `licenses.tar.gz` archive contains the plain text of all open source dependency licenses and source code for MPL-2.0 and EPL-1.0 licensed dependencies. This file will be included in the image used in the solution.

## License Mapping

Licenses are tagged using the short names defined by the [SPDX License List](https://spdx.org/license-list).

[MIT License (`MIT`)](https://spdx.org/licenses/MIT.html)
[BSD 2-Clause "Simplified" License (`BSD-2-Clause`)](https://spdx.org/licenses/BSD-2-Clause.html)
[BSD 3-Clause "New" or "Revised" License (`BSD-3-Clause`)](https://spdx.org/licenses/BSD-3-Clause.html)
[BSD 3-Clause Clear License (`BSD-3-Clause-Clear`)](https://spdx.org/licenses/BSD-3-Clause-Clear.html)
[ISC License (`ISC`)](https://spdx.org/licenses/ISC.html)
[Apache License 2.0 (`Apache-2.0`)](https://spdx.org/licenses/Apache-2.0.html)
[Mozilla Public License 2.0 (`MPL-2.0`)](https://spdx.org/licenses/MPL-2.0.html)
[The Unlicense (`Unlicense`)](https://spdx.org/licenses/Unlicense.html)
[Eclipse Publice License 1.0 (`EPL-1.0`)](https://github.com/eclipse/paho.mqtt.golang/blob/master/LICENSE)
[zlib License (`Zlib`)](https://spdx.org/licenses/Zlib.html)
