#!/bin/bash

set -o nounset
set -o errexit

#set -x

. ./libShell/echo_color.lib

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

export NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CONF_D="${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CONF_D}"
export NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CERTS="${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_CERTS}"
export NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_VHOST_D="${NGINX_REVERSE_ROOT_DATAS_NGINXPROXY_VHOST_D}"
export NGINX_REVERSE_ROOT_DATAS_USR_SHARE_NGINX_HTML="${NGINX_REVERSE_ROOT_DATAS_USR_SHARE_NGINX_HTML}"

start_services_func()
{
    pushd ${NGINX_REVERSE_ROOT}
    docker-compose -f reverseProxy.yml up -d httpd
    docker-compose -f reverseProxy.yml ps
    popd
}

stop_services_func()
{
    pushd ${NGINX_REVERSE_ROOT}
    docker-compose -f reverseProxy.yml down
    docker-compose -f reverseProxy.yml ps
    popd
}

#export DRONE_ROOT="/opt/cicd/drone"
DRONE_ROOT="${NGINX_REVERSE_ROOT}/cicd/drone"
export DRONE_TAG_SERVER="0.8.9"
export DRONE_TAG_AGENT="0.8.9"
export DRONE_DATAS="${DRONE_ROOT}/datas"

# drone server
export DRONE_HOST="https://drone.doryhub.com"
export DRONE_GITHUB_CLIENT="doryhub"
export DRONE_GITHUB_SECRET="doryhubpwd"
export DRONE_SECRET="drone"

deploy_drone_services_func()
{
    sudo mkdir -p ${DRONE_ROOT}
    sudo chown -R $USER:$USER ${DRONE_ROOT}

    cp -a ../../../libShell ${NGINX_REVERSE_ROOT}/
    cp ./reverseProxy.yml ${NGINX_REVERSE_ROOT}
    cp ./run.sh ${NGINX_REVERSE_ROOT}

    echo ""
    echo ""
    echoG "How to start drone services:"
    echoG "1) Populate DRONE_HOST DRONE_GITHUB_CLIENT DRONE_GITHUB_SECRET in ${NGINX_REVERSE_ROOT}/run.sh"
    echoG "2) cd into ${NGINX_REVERSE_ROOT}"
    echoG "3) ./run.sh startDrone"
    echo ""
    echoG "How to stop drone services:"
    echoG "1) cd into ${NGINX_REVERSE_ROOT}"
    echoG "2) ./run.sh stopDrone"
    echo ""
    echo ""
}

start_drone_services_func()
{
    pushd ${NGINX_REVERSE_ROOT}
    docker-compose -f reverseProxy.yml up -d drone-server drone-agent
    docker-compose -f reverseProxy.yml ps
    popd
}

stop_drone_services_func()
{
    pushd ${NGINX_REVERSE_ROOT}
    docker-compose -f reverseProxy.yml down
    docker-compose -f reverseProxy.yml ps
    popd
}

usage()
{
    echo ""
    echo ""
    echoG "Supported command:"
    echo "[deploy] Deploy nginx reverse proxy services."
    echo "[start] Start nginx reverse proxy services."
    echo "[stop] Stop nginx reverse proxy services."
    echo "[deployDrone] Deploy drone services."
    echo "[startDrone] Start drone services."
    echo "[stopDrone] Stop drone services."
    echo ""
    echo ""
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
    deployDrone) echo "Deploy drone services."
        deploy_drone_services_func
        ;;
    startDrone) echo "Start drone services."
        start_drone_services_func
        ;;
    stopDrone) echo "Stop drone services."
        stop_drone_services_func
        ;;
    *) echoR "Unknown command..."
        usage
        ;;
esac


