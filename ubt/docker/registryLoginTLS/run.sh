#!/bin/bash

set -o nounset
set -o errexit

set -x

REGISTRY_VERSION="2.7"

DOCKER_REG_ROOT="/opt/dockerRegs"

DOCKER_REG_ADMIN="admin"
DOCKER_REG_ADMIN_PWD="admin"

REGISTRY_NAME="myRegistry"
REGISTRY_DOMAIN="${REGISTRY_NAME}.com"

DOCKER_REG_CERTS_SRC_PATH="${HOME}/.acme.sh/${REGISTRY_DOMAIN}"
REGISTRY_HTTP_TLS_CERTIFICATE_NAME="fullchain.cer"
REGISTRY_HTTP_TLS_KEY_NAME="${REGISTRY_DOMAIN}.key"

DOCKER_REG_HOME="${DOCKER_REG_ROOT}/dockerRegDatasLogin"
DOCKER_REG_IMAGES="${DOCKER_REG_HOME}/images"
DOCKER_REG_AUTHS="${DOCKER_REG_HOME}/auths"
DOCKER_REG_CERTS="${DOCKER_REG_HOME}/certs"

setup_LetsEncrypt_func()
{
    curl  https://get.acme.sh | sh
    ${HOME}/.acme.sh/acme.sh  --issue -d ${REGISTRY_DOMAIN} --standalone
}

setupEnv_func()
{
    local docker_reg_home=$1
    local docker_reg_images=$2
    local docker_reg_auths=$3
    local docker_reg_admin=$4
    local docker_reg_admin_pwd=$5
    local docker_reg_certs=$6

    sudo mkdir -p ${docker_reg_images}
    sudo mkdir -p ${docker_reg_auths}
    sudo mkdir -p ${docker_reg_certs}
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
    cp ${DOCKER_REG_CERTS_SRC_PATH}/${REGISTRY_HTTP_TLS_CERTIFICATE_NAME} ${DOCKER_REG_CERTS}
    cp ${DOCKER_REG_CERTS_SRC_PATH}/${REGISTRY_HTTP_TLS_KEY_NAME} ${DOCKER_REG_CERTS}

    mkdir -p ./tmpConfigs
    cp configs/registryDocker-compose.yml ./tmpConfigs/
	sudo sed -i "s/REGISTRY_NAME/${REGISTRY_NAME}/" ./tmpConfigs/registryDocker-compose.yml
    local docker_reg_home_sed=$(echo ${docker_reg_home} |sed -e 's/\//\\\//g' )
	sudo sed -i "s/docker_reg_home/${docker_reg_home_sed}/" ./tmpConfigs/registryDocker-compose.yml
    local docker_reg_images_sed=$(echo ${docker_reg_images} |sed -e 's/\//\\\//g' )
	sudo sed -i "s/docker_reg_images/${docker_reg_images_sed}/" ./tmpConfigs/registryDocker-compose.yml
    local REGISTRY_HTTP_TLS_CERTIFICATE_NAME_sed=$(echo ${REGISTRY_HTTP_TLS_CERTIFICATE_NAME} |sed -e 's/\./\\\./g' )
	sudo sed -i "s/REGISTRY_HTTP_TLS_CERTIFICATE_NAME/${REGISTRY_HTTP_TLS_CERTIFICATE_NAME_sed}/" ./tmpConfigs/registryDocker-compose.yml
    local REGISTRY_HTTP_TLS_KEY_NAME_sed=$(echo ${REGISTRY_HTTP_TLS_KEY_NAME} |sed -e 's/\./\\\./g' )
	sudo sed -i "s/REGISTRY_HTTP_TLS_KEY_NAME/${REGISTRY_HTTP_TLS_KEY_NAME_sed}/" ./tmpConfigs/registryDocker-compose.yml

    cp ./tmpConfigs/registryDocker-compose.yml ${docker_reg_home}/docker-compose.yml

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
    echo "Then, login with: docker login ${REGISTRY_DOMAIN}"
    echo "Then, testing connection with curl ${REGISTRY_DOMAIN}/v2/_catalog"
    echo "Then, logout with: docker logout ${REGISTRY_DOMAIN}"
}

start_login_reg_func()
{
    pushd ${DOCKER_REG_HOME}
    docker-compose up -d
    popd
}

stop_reg_func()
{
    pushd ${DOCKER_REG_HOME}
    docker-compose down
    popd
}

case $1 in
    setupLetsEncrypt) echo "Setup Let's Encrypt..."
        setup_LetsEncrypt_func
        ;;
    setupEnv) echo "Setup registry running environment..."
        setupEnv_func ${DOCKER_REG_HOME} ${DOCKER_REG_IMAGES} ${DOCKER_REG_AUTHS} ${DOCKER_REG_ADMIN} ${DOCKER_REG_ADMIN_PWD} ${DOCKER_REG_CERTS}
        ;;
    checkEnv) echo "Checking registry running environment..."
        sudo tree ${DOCKER_REG_ROOT}
        ;;
    start) echo "Start registry: ${REGISTRY_NAME}..."
        start_login_reg_func
        ;;
    stop)
        stop_reg_func
        ;;
    *) echo "Unknown cmd: $1"
esac


