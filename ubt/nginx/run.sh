#!/bin/bash

set -o nounset
set -o errexit

#set -x

NGINX_VERSION="1.15.8"

NGINX_ROOT="/opt/nginx"
NGINX_BUILD="./build_nginx"

get_nginx_func()
{
    sudo mkdir -p ${NGINX_BUILD}
    sudo chown -R $USER:$USER ${NGINX_BUILD}
    pushd ${NGINX_BUILD}
    wget -c https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
    popd
}

build_nginx_func()
{
    pushd ${NGINX_BUILD}

    rm -rf nginx-${NGINX_VERSION}
    tar -zxf nginx-${NGINX_VERSION}.tar.gz

    pushd nginx-${NGINX_VERSION}
    ./configure --prefix="${NGINX_ROOT}"
    make
    popd

    popd
}

install_nginx_func()
{
    pushd ${NGINX_BUILD}/nginx-${NGINX_VERSION}
    sudo make install
    popd
}

usage_func()
{
    echo "Supported operations:"
    echo "[get]"
    echo "[build]"
    echo "[install]"
}


[ $# -lt 1 ] && usage_func && exit

case $1 in
    get) echo "Fetching source of nginx..."
        get_nginx_func
        ;;
    build) echo "Building nginx from source..."
        build_nginx_func
        ;;
    install) echo "Install nginx to ${NGINX_ROOT}"
        install_nginx_func
        ;;
    *) echo "Unknown cmd: $1"
esac



