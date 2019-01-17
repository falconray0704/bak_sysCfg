#!/bin/bash

set -o nounset
set -o errexit

#set -x


REGISTRY_NAME="preg"
REGISTRY_VERSION="2.7"

REGISTRY_DOMAIN="${REGISTRY_NAME}.io"
REGISTRY_PORT="5000"

DOCKER_REG_ROOT="/opt/dockerRegs"

DOCKER_REG_CERTS_NAME="domain"
DOCKER_REG_CERTS_NAME_CRET="${DOCKER_REG_CERTS_NAME}.crt"
DOCKER_REG_CERTS_NAME_KEY="${DOCKER_REG_CERTS_NAME}.key"


setupEnv_func()
{
    local docker_reg_home=$1
    local docker_reg_images=$2
    local docker_reg_certs=$3

    sudo mkdir -p ${docker_reg_images}
    sudo mkdir -p ${docker_reg_certs}
    sudo chown -R $USER:$USER ${docker_reg_home}
}

setupEnv_no_auth_func()
{
    local docker_reg_home=$1
    local docker_reg_images=$2

    sudo mkdir -p ${docker_reg_images}
    sudo chown -R $USER:$USER ${docker_reg_home}

    mkdir -p ./tmpConfigs
    cp configs/registryDaemon.json ./tmpConfigs/

	sudo sed -i "s/REGISTRY_DOMAIN/${REGISTRY_DOMAIN}/" ./tmpConfigs/registryDaemon.json
	sudo sed -i "s/REGISTRY_PORT/${REGISTRY_PORT}/" ./tmpConfigs/registryDaemon.json

    sudo cp ./tmpConfigs/registryDaemon.json /etc/docker/daemon.json
    sudo systemctl restart docker.service

    echo "Set: ${REGISTRY_DOMAIN} into /etc/hosts"
    echo "Then, testing connection with curl http://preg.io:5000/v2/_catalog"

}

create_certs_func()
{
    pushd ${DOCKER_REG_CERTS}
    openssl req -newkey rsa:4096 -nodes -sha256 -keyout ${DOCKER_REG_CERTS}/${DOCKER_REG_CERTS_NAME_KEY} -x509 -days 3650 -out ${DOCKER_REG_CERTS}/${DOCKER_REG_CERTS_NAME_CRET}
    popd
}

start_reg_func()
{
    local regName=$1
    local regDataVolume=$2
    docker run -d \
        -p 5000:5000 \
        --restart=always \
        --name ${regName} \
        -v ${regDataVolume}:/var/lib/registry \
        -v ${DOCKER_REG_CERTS}/:/certs/ \
        -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/${DOCKER_REG_CERTS_NAME_CRET} \
        -e REGISTRY_HTTP_TLS_KEY=/certs/${DOCKER_REG_CERTS_NAME_KEY} \
        registry:2
}

start_reg_func_test()
{
    local regName=$1
    local regDataVolume=$2
    docker run -d \
        -p 5000:5000 \
        --restart=always \
        --name ${regName} \
        -v ${regDataVolume}:/var/lib/registry \
        registry:2
}

start_no_auth_reg_func()
{
    local regName=$1
    local regDataVolume=$2
    docker run -d \
        -p 5000:5000 \
        --restart=always \
        --name ${regName} \
        -v ${regDataVolume}:/var/lib/registry \
        registry:${REGISTRY_VERSION}
}

stop_reg_func()
{
    local regName=$1
    docker container stop ${regName} && docker container rm -v ${regName}
}

case $1 in
    setupEnv) echo "Setup registry running environment..."
        DOCKER_REG_HOME="${DOCKER_REG_ROOT}/dockerRegDatas"
        DOCKER_REG_IMAGES="${DOCKER_REG_HOME}/images"
        DOCKER_REG_CERTS="${DOCKER_REG_HOME}/certs"
        setupEnv_func ${DOCKER_REG_HOME} ${DOCKER_REG_IMAGES} ${DOCKER_REG_CERTS}
        ;;
    setupEnvNoAuth) echo "Setup no auth registry running environment..."
        DOCKER_REG_HOME="${DOCKER_REG_ROOT}/dockerRegDatasNoAuth"
        DOCKER_REG_IMAGES="${DOCKER_REG_HOME}/images"
        setupEnv_no_auth_func ${DOCKER_REG_HOME} ${DOCKER_REG_IMAGES}
        ;;
    checkEnv) echo "Checking registry running environment..."
        sudo tree ${DOCKER_REG_ROOT}
        ;;
    createCerts) echo "Create registry cert and key..."
        create_certs_func
        ;;
    startNoAuth) echo "Start registry: ${REGISTRY_NAME}..."
        DOCKER_REG_HOME="${DOCKER_REG_ROOT}/dockerRegDatasNoAuth"
        DOCKER_REG_IMAGES="${DOCKER_REG_HOME}/images"
        start_no_auth_reg_func ${REGISTRY_NAME} ${DOCKER_REG_IMAGES}
        ;;
    start) echo "Start registry: ${REGISTRY_NAME}..."
        DOCKER_REG_HOME="${DOCKER_REG_ROOT}/dockerRegDatas"
        DOCKER_REG_CERTS="${DOCKER_REG_HOME}/certs"
        DOCKER_REG_IMAGES="${DOCKER_REG_HOME}/images"
        start_reg_func ${REGISTRY_NAME} ${DOCKER_REG_IMAGES}
        ;;
    stop)
        stop_reg_func ${REGISTRY_NAME}
        ;;
    checkDocker) echo "Checking docker env..."
        check_Docker_Env_func
        ;;
    *) echo "Unknown cmd: $1"
esac


