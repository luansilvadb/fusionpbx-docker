#!/bin/bash
ARCH=$1

if [[ -z $1 ]]; then
    ARCH=arm/v7
fi

pushd freeswitch
docker buildx build --platform linux/${ARCH} --platform linux/amd64 --push -t crazyquark/freeswitch .
popd