#!/bin/sh -e

slug=$1
local_dir=`realpath $2`

image=`docker build -q .`

docker run \
       --network none \
       --read-only \
       --mount type=bind,source=${local_dir},target=/dir\
       --rm \
       -it $image $slug /dir/

docker image rm $image
