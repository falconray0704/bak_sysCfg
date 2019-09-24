#!/bin/bash

set -o nounset
set -o errexit

. ../libShell/echo_color.lib


install_DockerCompose_func()
{
    # refer to https://www.berthon.eu/2017/getting-docker-compose-on-raspberry-pi-arm-the-easy-way/
    local BuildRoot:="/opt/github/docker"
    mkdir -p ${BuildRoot}
    pushd ${BuildRoot}
    git clone https://github.com/docker/compose.git
    pushd compose
    git checkout release
    docker build -t docker-compose:armhf -f Dockerfile.armhf .
    docker run --rm --entrypoint="script/build/linux-entrypoint" -v $(pwd)/dist:/code/dist -v $(pwd)/.git:/code/.git "docker-compose:armhf"
    popd
    popd
}

install_Docker_func()
{
    # refer to https://www.raspberrypi.org/blog/docker-comes-to-raspberry-pi/
    curl -sSL https://get.docker.com | sh

    # use Docker as a non-root user
    sudo usermod -aG docker pi

    sudo reboot
}

check_Docker_Env_func()
{
    docker info
    docker version
    docker run -i -t resin/rpi-raspbian
}

print_usage_func()
{
    echoY "Supported operations:"
    echo "install"
    echo "check"
    echo "compose"
}

[ $# -lt 1 ] && print_usage_func && exit 1

case $1 in
    install) echoY "Installing ..."
        install_Docker_func
        ;;
    check) echoY "Checking docker env..."
        check_Docker_Env_func
        ;;
    compose) echoY "Installing Docker Compose ..."
        install_DockerCompose_func
        ;;
    *) echoR "Unknown cmd: $1"
        print_usage_func
        ;;
esac


