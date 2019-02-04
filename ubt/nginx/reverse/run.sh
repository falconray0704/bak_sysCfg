#!/bin/bash

set -o nounset
set -o errexit

#set -x



NGINX_ROOT="/opt/nginx"
NGINX_PROXY_ROOT="${NGINX_ROOT}/proxy"
NGINX_PROXY_REVERSE_ROOT="${NGINX_PROXY_ROOT}/reverse"
NGINX_PROXY_REVERSE_ROOT_CONF_D="${NGINX_PROXY_REVERSE_ROOT}/conf.d"

deploy_func()
{
    sudo mkdir -p ${NGINX_PROXY_REVERSE_ROOT_CONF_D}
    sudo chown -R $USER:$USER ${NGINX_PROXY_REVERSE_ROOT}

    cp ./docker-compose-reverse.yml ${NGINX_PROXY_REVERSE_ROOT}/
    cp ./run.sh ${NGINX_PROXY_REVERSE_ROOT}/
    cp ./nginx.tmpl ${NGINX_PROXY_REVERSE_ROOT_CONF_D}/

}

launch_services_func()
{
    export NGINX_PROXY_REVERSE_ROOT_CONF_D="${NGINX_PROXY_REVERSE_ROOT_CONF_D}"

    pushd ${NGINX_PROXY_REVERSE_ROOT}
    docker-compose -f docker-compose-reverse.yml up -d
    docker-compose -f docker-compose-reverse.yml ps
    popd
}

stop_services_func()
{
    export NGINX_PROXY_REVERSE_ROOT_CONF_D="${NGINX_PROXY_REVERSE_ROOT_CONF_D}"

    pushd ${NGINX_PROXY_REVERSE_ROOT}
    docker-compose -f docker-compose-reverse.yml down
    docker-compose -f docker-compose-reverse.yml ps
    popd
}

usage()
{
    echo "Supported command:"
    echo "[deploy]"
    echo "[start]"
    echo "[stop]"
}

[ $# -lt 1 ] && usage && exit

case $1 in
    deploy) echo "Deploying reverse proxy to ${NGINX_PROXY_REVERSE_ROOT} ..."
        deploy_func
        ;;
    start) echo "Launch services with docker-compose..."
        launch_services_func
        ;;
    stop) echo "Stop services with docker-compose..."
        stop_services_func
        ;;
    *) echo "Unknown command..."
        ;;
esac


