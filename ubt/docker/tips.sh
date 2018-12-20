#!/bin/bash

set -o nounset
set -o errexit

#set -x

tips_run_func()
{
    echo 'Example:'
    echo 'sudo docker run -i -t --name mytest ubuntu:latest /bin/bash'
    echo 'Options:'
    echo '[-i] Interaction mode.'
    echo '[-t] Launch a terminal, use it with "-i" option.'
    echo '[-c] Assign cpu shares.'
    echo '[-m] Assign memory. Support:(B,K,M,G)'
    echo '[-v] Assign volume. Format: [host-dir]:[container-dir]:[rw|ro]'
    echo '[-p] Expose port from container. Format:[host-port]:[container-port]'
}

tips_env_func()
{
    echo "docker info"
    echo "docker version"
}

tips_help_func()
{
    #echo "1) Fetch logs of the container:"
    #echo "docker logs -f peer0.org1.example.com"

    #echo "2) Enter container's bash:"
    #echo "docker exec -it <container's name> bash"

    echo "Supported tips:"
    echo '1) [env] Tips for getting docker Env infos.'
    echo '2) [run] Tips for "run" command.'
}


case $1 in
    help) echo "Tips for docker manipulations:"
        tips_help_func
        ;;
    env) echo "Tips for geting docker environment infos:"
        tips_env_func
        ;;
    run) echo '2) [run] Tips for "run" command.'
        tips_run_func
        ;;
    *) echo "Unknown cmd: $1"
esac


