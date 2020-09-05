#!/bin/sh -e

slug=$1
input_dir=`realpath $2`
output_dir=`realpath $3`

image=`docker build -q .`

docker run \
       --network none \
       --read-only \
       --mount type=bind,source=${input_dir},target=/input\
       --mount type=bind,source=${output_dir},target=/output\
       --rm \
       -it $image $slug /input/ /output/

docker image rm $image
