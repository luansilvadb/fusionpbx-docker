#!/bin/bash
ARCH=$1

if [[ -z $1 ]]; then
    ARCH=arm/v7
fi

TAG=${ARCH/\//}

pushd freeswitch
docker buildx build --no-cache --platform linux/${ARCH} --push -t crazyquark/freeswitch .
popd