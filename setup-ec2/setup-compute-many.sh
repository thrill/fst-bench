#!/bin/bash -x

set -e

pushd `dirname $0` > /dev/null
DIR=`pwd`
popd > /dev/null

for box in $@; do
    $DIR/setup-compute.sh $box &
    sleep 5s
done

for box in $@; do
    wait
done
