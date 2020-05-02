#!/bin/bash
pushd freeswitch
docker build -t crazyquark/freeswitch .
popd