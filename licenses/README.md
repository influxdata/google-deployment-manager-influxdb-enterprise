# How to handle licenses

GCP Marketplace requires every revision of a Marketplace listing to provide up-to-date information on licensing. The GCP Marketplace OSS checklist form is [here](https://docs.google.com/spreadsheets/d/1qkpFjAYfqadg7IVmJGEpzEPxyhjE6L8Xi5epE98OCw0/edit#gid=0) (this is an authenticated link).

## Lists of licenses and dependency licenses

The following projects are currently included in the base image.

1. InfluxDB Enterprise
    - [Project license](https://docs.influxdata.com/enterprise_influxdb/v1.6/about-the-project/#commercial-license-https-www-influxdata-com-legal-slsa)
    - [Licenses of dependencies](https://raw.githubusercontent.com/influxdata/docs.influxdata.com/master/content/enterprise_influxdb/v1.6/about-the-project/_index.md)
2. InfluxDB OSS (main root dependency of InfluxDB Enterprise)
    - [Project license](https://raw.githubusercontent.com/influxdata/influxdb/v1.6.2/LICENSE)
    - [Licenses of dependencies](https://raw.githubusercontent.com/influxdata/influxdb/v1.6.2/LICENSE_OF_DEPENDENCIES.md)
3. Telegraf
    - [Project license](https://raw.githubusercontent.com/influxdata/telegraf/1.7.4/LICENSE)
    - [License of Dependencies](https://raw.githubusercontent.com/influxdata/telegraf/1.7.4/docs/LICENSE_OF_DEPENDENCIES.md)

## Compile licenses list

This directory contains the four types of files that need to be successively assembled using the following process:

1. `[influxdb|influxdb-enterprise|telegraf]-licenses.csv`: These files contain the list of licenses and additional info to be included in the GCP Marketplace open source compliance form.
    - Manually create each CSV from the content found in the links of the [preceding section]().
2. `license-links-[raw|html|mpl].txt`: These files contain the links to all licenses to be listed in the `ALL_LICENSES` file. The list is manually created from the links in the preceding section.
    - The `license-links-raw.txt` file should be a newline separated list of all links to licenses from all the product-specific files. Only links that return a direct request of a license file in plaintext should be included, e.g. `https://raw.githubusercontent.com/...`. Includes MPL licenses.
    - The `license-links-html.txt` file should be a list of links to all other licenses from the product-specific files that do not have a plaintext download link, e.g. `https://github.com/chuckpreslar/rcon#license` and `http://mattn.mit-license.org/2013`.
    - The `license-links-mpl.txt` file should be a list of links to the _source code_ of all dependencies from the product-specific files which are licensed with a Mozilla Public License (MPL) or MPL 2.0, e.g. `https://github.com/hashicorp/raft/archive/master.zip`.
3. `licenses.tar.gz`: This archive is the master file of the full text of all licenses and MPL-licensed source code. This is the file that is actually uploaded to the VM image used in the GCP Marketplace BYOL listing. It needs to be recompiled for every update to the base image.
    - Run the `compile.sh` script in this directory to fetch the plaintext of all licenses in the `license-links-raw.txt` file, the HTML of all licenses in `license-links-raw.txt`, and all source code from the links listed in the `license-links-mpl.txt` file, then put the files into the `licenses.tar.gz` archive.

That's it! The license compilition process currently requires many manual steps. If you can find a way to streamline this process, please contribute! Thanks!
