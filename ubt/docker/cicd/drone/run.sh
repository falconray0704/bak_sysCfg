#!/bin/sh

#set -x

DRONE_HOME="/opt/cicd/drone"

deploy_func()
{
    sudo mkdir -p ${DRONE_HOME}
    sudo chown -R $USER:$USER ${DRONE_HOME}

    cp ./docker-compose.yml ${DRONE_HOME}
    cp ./env.sh ${DRONE_HOME}
    cp ./run.sh ${DRONE_HOME}

    echo "Launch steps:"
    echo "Populate informations into ${DRONE_HOME}/env.sh."
    echo "source ${DRONE_HOME}/env.sh"
    echo "docker-compose up -d"
}

usage()
{
    echo "Supported command:"
    echo "[deploy]"
}

[ $# -lt 1 ] && usage && exit

case in $0
    deploy) echo "Deploying to ${DRONE_HOME} ..."
        deploy_func
        ;;
    *) echo "Unknown command..."
        ;;
esac


