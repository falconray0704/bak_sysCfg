#!/bin/bash

set -o nounset
set -o errexit

set -x


REGISTRY_NAME="preg"
REGISTRY_VERSION="2.7"

REGISTRY_DOMAIN="${REGISTRY_NAME}.io"
REGISTRY_PORT="5000"

DOCKER_REG_ROOT="/opt/dockerRegs"

DOCKER_REG_HOME="${DOCKER_REG_ROOT}/dockerRegDatasLogin"
DOCKER_REG_IMAGES="${DOCKER_REG_HOME}/images"
DOCKER_REG_AUTHS="${DOCKER_REG_HOME}/auths"
DOCKER_REG_ADMIN="admin"
DOCKER_REG_ADMIN_PWD="admin"

setupEnv_func()
{
    local docker_reg_home=$1
    local docker_reg_images=$2
    local docker_reg_auths=$3
    local docker_reg_admin=$4
    local docker_reg_admin_pwd=$5

    sudo mkdir -p ${docker_reg_images}
    sudo mkdir -p ${docker_reg_auths}
    sudo chown -R $USER:$USER ${docker_reg_home}

    pushd ${docker_reg_auths}
    echo "Creating registry's Administrator:${docker_reg_admin}"
    #htpasswd -cB htpasswd ${docker_reg_admin}
    docker run \
        --name "loginpwd" \
        --entrypoint htpasswd \
        registry:${REGISTRY_VERSION} -Bbn ${docker_reg_admin} \
        ${docker_reg_admin_pwd} > htpasswd
    docker container stop loginpwd && docker container rm -v loginpwd
    popd

    mkdir -p ./tmpConfigs
    cp configs/registry/registryDaemon.json ./tmpConfigs/

	sudo sed -i "s/REGISTRY_DOMAIN/${REGISTRY_DOMAIN}/" ./tmpConfigs/registryDaemon.json
	sudo sed -i "s/REGISTRY_PORT/${REGISTRY_PORT}/" ./tmpConfigs/registryDaemon.json

    cp configs/registry/registryConfig.yml ./tmpConfigs/
    cp configs/registry/registryDocker-compose.yml ./tmpConfigs/
	sudo sed -i "s/REGISTRY_NAME/${REGISTRY_NAME}/" ./tmpConfigs/registryDocker-compose.yml
    local docker_reg_home_sed=$(echo ${docker_reg_home} |sed -e 's/\//\\\//g' )
	sudo sed -i "s/docker_reg_home/${docker_reg_home_sed}/" ./tmpConfigs/registryDocker-compose.yml
    local docker_reg_images_sed=$(echo ${docker_reg_images} |sed -e 's/\//\\\//g' )
	sudo sed -i "s/docker_reg_images/${docker_reg_images_sed}/" ./tmpConfigs/registryDocker-compose.yml

    cp ./tmpConfigs/registryConfig.yml ${docker_reg_home}/config.yml
    cp ./tmpConfigs/registryDocker-compose.yml ${docker_reg_home}/docker-compose.yml

    sudo cp ./tmpConfigs/registryDaemon.json /etc/docker/daemon.json
    sudo systemctl restart docker.service

    echo ""
    echo ""
    echo "Start registry with docker-compose:"
    echo "docker-compose up -d"
    echo "Stop registry with docker-compose:"
    echo "docker-compose down"
    echo ""
    echo ""
    echo "Set: ${REGISTRY_DOMAIN} into /etc/hosts"
    echo "Then, login with: docker login preg.io:5000"
    echo "Then, testing connection with curl http://preg.io:5000/v2/_catalog"
    echo "Then, logout with: docker logout preg.io:5000"
}

start_login_reg_func()
{
    local regName=$1
    local regDataVolume=$2
    local docker_reg_auths=$3

    docker run -d \
        -p 5000:5000 \
        --restart=always \
        --name ${regName} \
        -v "${regDataVolume}:/var/lib/registry" \
        -v "${docker_reg_auths}:/auth" \
        -e "REGISTRY_AUTH=htpasswd" \
        -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
        -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
        registry:${REGISTRY_VERSION}
}

stop_reg_func()
{
    local regName=$1
    docker container stop ${regName} && docker container rm -v ${regName}
}

case $1 in
    setupEnv) echo "Setup registry running environment..."
        setupEnv_func ${DOCKER_REG_HOME} ${DOCKER_REG_IMAGES} ${DOCKER_REG_AUTHS} ${DOCKER_REG_ADMIN} ${DOCKER_REG_ADMIN_PWD}
        ;;
    checkEnv) echo "Checking registry running environment..."
        sudo tree ${DOCKER_REG_ROOT}
        ;;
    start) echo "Start registry: ${REGISTRY_NAME}..."
        start_login_reg_func ${REGISTRY_NAME} ${DOCKER_REG_IMAGES} ${DOCKER_REG_AUTHS}
        ;;
    stop)
        stop_reg_func ${REGISTRY_NAME}
        ;;
    *) echo "Unknown cmd: $1"
esac


