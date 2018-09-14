#!/bin/bash

cat license-links-raw.txt | while read -r line || [[ -n "$line" ]]; do
    echo -e "-----\nLicense for $line:\n$(curl -s $line)\n" >> ALL_LICENSES
done
echo "Successfully fetched license plaintext to ALL_LICENSES"

mkdir mpl-source
cat license-links-mpl.txt | while read -r line || [[ -n "$line" ]]; do
    curl -s $line > mpl-source/test-$(echo "$line" | tail -c 20 | sed 's/\//-/g')
done
echo "Successfully fetched MPL-licensed source to MPL_SOURCE.tar.gz"
