#!/bin/bash

set -o nounset
set -o errexit

#set -x

VERSION_DOCKER_MACHINE="0.16.1"

install_DockerMachine_func()
{
    curl -L https://github.com/docker/machine/releases/download/v${VERSION_DOCKER_MACHINE}/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
        chmod +x /tmp/docker-machine &&
        sudo cp /tmp/docker-machine /usr/local/bin/docker-machine

    base=https://raw.githubusercontent.com/docker/machine/v${VERSION_DOCKER_MACHINE}
    for i in docker-machine-prompt.bash docker-machine-wrapper.bash docker-machine.bash
    do
          sudo wget "$base/contrib/completion/bash/${i}" -P /etc/bash_completion.d
    done
}

uninstall_DockerMachine_func()
{
    echo "Get full uninstall, refer to: https://docs.docker.com/machine/install-machine"
    sudo rm $(which docker-machine)

    for i in docker-machine-prompt.bash docker-machine-wrapper.bash docker-machine.bash
    do
          sudo rm -rf /etc/bash_completion.d/${i}
    done
}

usage_func()
{
    echo "Supported functionalities:"
    echo "[installDockerMachine]"
    echo "[uninstallDockerMachine]"
}

[ $# -lt 1 ] && usage_func && exit

case $1 in
    installDockerMachine) echo "Installing Docker Machine ..."
        install_DockerMachine_func
        ;;
    uninstallDockerMachine) echo "Uninstalling Docker Machine ..."
        uninstall_DockerMachine_func
        ;;
    *) echo "Unknown cmd: $1"
esac


