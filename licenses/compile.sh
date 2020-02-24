#!/bin/bash

# Uncomment the following line to enable debug output
# set -euxo pipefail

rm licenses.tar.gz || true

tmp="$(mktemp -d -t gcp-marketplace-license)"
cwd="$(pwd)"

# This script will only compile licenses on Github that have a license file. The
# license text and source for libraries hosted on other sites or with no license
# file needs to be compiled by hand before running this script.
#
# To manually compile a license, put the license text in a file in the ./html
# directory with the following name: ./html/{license-short-name}/{library-name}
#
# If source is required, a zip file of the library should be put in the
# following directory: ./html/{license-short-name}/source/{library-name}.zip
cp -r manual/* "${tmp}/"

cd "${tmp}"

cat ${cwd}/licenses.csv | grep -v -e '#' -e '^ ' -e '^$' | while read -r line || [[ -n "${line}" ]]; do
    license="$( echo ${line} | cut -d ',' -f 1 )"
    name="$( echo ${line} | cut -d ',' -f 2 )"
    link="$( echo ${line} | cut -d ',' -f 3 )"
    mkdir -p "${license}"
    curl -s "$( echo ${link} | sed 's|https://github|https://raw.githubusercontent|; s|/blob/|/|' )" \
        --output "${license}/$( echo ${name} | sed 's|[/.]|-|g' )"
    if [[ "${license}" == 'MPL-2.0' || "${license}" == "EPL-1.0" ]]; then
        mkdir -p "${license}/source"
        curl -s "$( echo ${link} | sed 's|/blob/master/.*|/zip/master|; s|//github.com|//codeload.github.com|' )" \
            --output "${license}/source/$( echo ${name} | sed 's|[/.]|-|g' ).zip"
    fi
done

tar czvf "${cwd}/licenses.tar.gz" .

cd "${cwd}"

echo "These licenses will need to be added manually: $( cat ${cwd}/licenses.csv | grep -e '#' | grep -v '^#' | cut -d ',' -f 2 )"
