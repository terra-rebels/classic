#!/usr/bin/env bash

set -eo pipefail

echo "Generating gogo proto code"
proto_dirs=$(find ./proto -path -prune -o -name '*.proto' -print0 | xargs -0 -n1 dirname | sort | uniq)
for dir in $proto_dirs; do
    for file in $(find "${dir}" -maxdepth 1 -name '*.proto'); do
        buf generate --template buf.gen.gogo.yaml $file
    done
done

# move proto files to the right places
cp -r github.com/terra-money/core/* ./
rm -rf github.com
