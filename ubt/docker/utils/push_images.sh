#!/bin/bash

set +x

. ../../../libShell/echo_color.lib

#REGISTRY="127.0.0.1:5000"
REGISTRY="xperegrine.com"

usage()
{
    docker images
    echo ""
    echo "Usage: $0 registry1:tag1 [registry2:tag2...]"
}

[ $# -lt 1 ] && usage && exit

echoB "The registry server is ${REGISTRY}"

for image in "$@"
do
    echoB "Uploading ${image} ..."
    docker tag $image ${REGISTRY}/${image}
    docker push ${REGISTRY}/${image}
    docker rmi ${REGISTRY}/${image}
    echoG "Done"
done


