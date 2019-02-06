#!/bin/bash

set -o nounset
set -o errexit

#set -x

NGINX_ROOT="/opt/nginx"
NGINX_PROXY_ROOT="${NGINX_ROOT}/proxy"
NGINX_REVERSE_ROOT="${NGINX_PROXY_ROOT}/reverse"
NGINX_REVERSE_ROOT_DATAS="${NGINX_REVERSE_ROOT}/datas"
NGINX_REVERSE_ROOT_DATAS_NGINXPROXY="${NGINX_REVERSE_ROOT_DATAS}/nginx_proxy"
NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CONF_D="${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY}/conf.d"

# to store certificates, private keys and ACME account keys (readonly for the nginx-proxy container).
NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CERTS="${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY}/certs"
# to change the configuration of vhosts (required so the CA may access http-01 challenge files).
NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_VHOST_D="${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY}/vhost.d"
#  to write http-01 challenge files.
NGINX_REVERSE_ROOT_DATAS_USR_SHARE_NGINX_HTML="${NGINX_REVERSE_ROOT_DATAS}/usr/share/nginx/html"

deploy_nginx_proxy_reverse_func()
{
    sudo mkdir -p ${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CONF_D}
    sudo chown -R $USER:$USER ${NGINX_REVERSE_ROOT}

    cp ./reverseProxy.yml ${NGINX_REVERSE_ROOT}/
    cp ./run.sh ${NGINX_REVERSE_ROOT}/
    cp ./nginx.tmpl ${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CONF_D}/
}

deploy_LetsEncrypt_func()
{
    sudo mkdir -p ${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CERTS}
    sudo mkdir -p ${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_VHOST_D}
    sudo mkdir -p ${NGINX_REVERSE_ROOT_DATAS_USR_SHARE_NGINX_HTML}

    sudo chown -R $USER:$USER ${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CERTS}
    sudo chown -R $USER:$USER ${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_VHOST_D}
    sudo chown -R $USER:$USER ${NGINX_REVERSE_ROOT_DATAS_USR_SHARE_NGINX_HTML}

}

deploy_func()
{
    deploy_nginx_proxy_reverse_func
    deploy_LetsEncrypt_func

}

start_services_func()
{
    export NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CONF_D="${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CONF_D}"
    export NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CERTS="${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CERTS}"
    export NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_VHOST_D="${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_VHOST_D}"
    export NGINX_REVERSE_ROOT_DATAS_USR_SHARE_NGINX_HTML="${NGINX_REVERSE_ROOT_DATAS_USR_SHARE_NGINX_HTML}"

    pushd ${NGINX_REVERSE_ROOT}
    docker-compose -f reverseProxy.yml up -d
    docker-compose -f reverseProxy.yml ps
    popd
}

stop_services_func()
{
    export NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CONF_D="${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CONF_D}"
    export NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CERTS="${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CERTS}"
    export NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_VHOST_D="${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_VHOST_D}"
    export NGINX_REVERSE_ROOT_DATAS_USR_SHARE_NGINX_HTML="${NGINX_REVERSE_ROOT_DATAS_USR_SHARE_NGINX_HTML}"

    pushd ${NGINX_REVERSE_ROOT}
    docker-compose -f reverseProxy.yml down
    docker-compose -f reverseProxy.yml ps
    popd
}

usage()
{
    echo "Supported command:"
    echo "[deploy]"
    echo "[start] Start nginx reverse proxy services."
    echo "[stop] Stop nginx reverse proxy services."
}

[ $# -lt 1 ] && usage && exit

case $1 in
    deploy) echo "Deploying reverse proxy to ${NGINX_REVERSE_ROOT} ..."
        deploy_func
        ;;
    start) echo "Launch reverse proxy services with docker-compose..."
        start_services_func
        ;;
    stop) echo "Stop reverse proxy services with docker-compose..."
        stop_services_func
        ;;
    *) echo "Unknown command..."
        ;;
esac


