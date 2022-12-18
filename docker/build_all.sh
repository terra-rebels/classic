#!/bin/bash

VERSION="${1:-a6f1a39f00c2723b62f42d40d024bd1181225a8d}"

docker build --build-arg version=$VERSION -t terrarebels/terraclassic.terrad-binary:$VERSION . -f ./Dockerfile.terraclassic.terrad-binary
docker build --build-arg version=$VERSION --build-arg chainid=columbus-5 -t terrarebels/terraclassic.terrad-node:$VERSION-columbus-5 .
docker build --build-arg version=$VERSION --build-arg chainid=rebel-1    -t terrarebels/terraclassic.terrad-node:$VERSION-rebel-1 .
docker build --build-arg version=$VERSION --build-arg chainid=rebel-2    -t terrarebels/terraclassic.terrad-node:$VERSION-rebel-2 .

