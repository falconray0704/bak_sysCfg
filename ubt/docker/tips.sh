#!/bin/bash

set -o nounset
set -o errexit

#set -x


tips_inspect_func()
{
    echo 'Example:'
    echo "docker inspect --format='{{.NetworkSettings.IPAddress}}' mytest"
    echo "docker inspect --format='{{.Config.Volumes}}' mytest"
    echo "docker inspect --format='{{.HostConfig.Binds}}' mytest"
}

tips_restart_func()
{
    echo 'Example:'
    echo 'sudo docker restart mytest'
}

tips_stop_func()
{
    echo 'Example:'
    echo 'sudo docker stop mytest'
}

tips_start_func()
{
    echo 'Example:'
    echo 'sudo docker start -ai mytest'
    echo 'Options:'
    echo '[-a] Attach STDOUT/STDERR and forward signals.'
    echo "[-i] Attach container\'s STDIN."
}

tips_rmi_func()
{
    echo 'Example:'
    echo 'sudo docker rmi ubuntu:latest'
}

tips_rm_func()
{
    echo 'Example:'
    echo 'sudo docker rm -fv mytest'
    echo 'Options:'
    echo '[-f] Force the removal of a running container (uses SIGKILL)'
    echo '[-l] Remove the specified link'
    echo '[-v] Remove the volumes associated with the container'
}

tips_images_func()
{
    echo 'Example:'
    echo 'sudo docker images -a'
    echo 'Options:'
    echo '[-a] List all docker images.'
}

tips_ps_func()
{
    echo 'Example:'
    echo 'sudo docker ps -a'
    echo 'Options:'
    echo '[-a] List all docker containers.'
}

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
    echo '001) [env]      Tips for getting docker Env infos.'
    echo '002) [run]      Tips for "run" command. Run container.'
    echo '003) [ps]       Tips for "ps" command. List containers.'
    echo '004) [images]   Tips for "images" command. List images.'
    echo '005) [rm]       Tips for "rm" command. Remove container.'
    echo '006) [rmi]      Tips for "rmi" command. Remove Image.'
    echo '007) [start]    Tips for "start" command. Start container.'
    echo '008) [stop]     Tips for "stop" command. Stop container.'
    echo '009) [restart]  Tips for "restart" command. Restart container.'
    echo '010) [inspect]  Tips for "inspect" command. Get informations about images or containers.'
}


case $1 in
    help) echo "Tips for docker manipulations:"
        tips_help_func
        ;;
    env) echo "001) [env] Tips for geting docker environment infos:"
        tips_env_func
        ;;
    run) echo '002) [run] Tips for "run" command.'
        tips_run_func
        ;;
    ps) echo '003) [ps]   Tips for "ps" command.'
        tips_ps_func
        ;;
    images) echo '004) [images]   Tips for "images" command.'
        tips_images_func
        ;;
    rm) echo '005) [rm]   Tips for "rm" command.'
        tips_rm_func
        ;;
    rmi) echo '006) [rmi]   Tips for "rmi" command.'
        tips_rmi_func
        ;;
    start) echo '007) [start]    Tips for "start" command. Start container.'
        tips_start_func
        ;;
    stop) echo '008) [stop]    Tips for "stop" command. Stop container.'
        tips_stop_func
        ;;
    restart) echo '009) [restart]     Tips for "restart" command. Restart container.'
        tips_restart_func
        ;;
    inspect) echo '010) [inspect]  Tips for "inspect" command. Get informations about images or containers.'
        tips_inspect_func
        ;;
    *) echo "Unknown cmd: $1"
esac


