#!/bin/bash

set -euxo pipefail

rm licenses.tar.gz || true

tmp="$(mktemp -d -t gcp-marketplace-license)"
cwd=$(pwd)

cd $tmp

cat $cwd/license-links-raw.txt | while read -r line || [[ -n "$line" ]]; do
    curl -s "${line}" --output "$(echo ${line} \
        | tr '[:upper:]' '[:lower:]' \
        | sed '
        s|https://raw.githubusercontent|github|; s|https://github|github|; s|https://||
s|[/.#+]|-|g; s/-master-/-/; s/-license/-/; s/-txt//; s/-md//; s/---/-/; s/-$//
        s|$|-license.txt|
        ' )"
done

cat $cwd/license-links-html.txt | while read -r line || [[ -n "$line" ]]; do
    curl -s "${line}" --output "$(echo ${line} \
        | tr '[:upper:]' '[:lower:]' \
        | sed '
        s|https://raw.githubusercontent|github|; s|https://github|github|; s|https://||; s|http://||
        s|[/.#+:]|-|g; s/-master-/-/; s/-license/-/; s/-txt//; s/-md//; s/---/-/; s/-$//
        s|$|license.html|
        ' )"
done

cat $cwd/license-links-mpl.txt | while read -r line || [[ -n "$line" ]]; do
    curl -s "${line}" --output "$(echo ${line} | sed 's|https://||' | sed 's|/|-|g' | sed 's|-archive-master\.zip$|-source\.zip|' )"
done

tar czvf $cwd/licenses.tar.gz .

cd $cwd
