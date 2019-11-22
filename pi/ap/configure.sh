#!/bin/bash

# refer to:
# https://hub.docker.com/r/alexandreoda/vlc
# docker pull alexandreoda/vlc

set -e
#set -x

. ../../libShell/echo_color.lib
. ../../libShell/sysEnv.lib

APDEV_NAME=""
APDEV_MAC="macAddr"

rename_AP_device_func()
{

    sudo lshw -C network | grep -E "-network|description|logical name|serial"
    echoY "Please input the name of device which use for AP:"
    read APDEV_NAME
    APDEV_MAC=$(get_iether_MAC ${APDEV_NAME})
    if [ ${APDEV_MAC} ]
    then
        echo "device mac: ${APDEV_MAC}"
        cp ./cfgs/70-piAPDev_network_interfaces.rules ./tmp/
        sed -i "s/macAddr/${APDEV_MAC}/" ./tmp/70-piAPDev_network_interfaces.rules
        sudo cp ./tmp/70-piAPDev_network_interfaces.rules /etc/udev/rules.d/
        cat ./tmp/70-piAPDev_network_interfaces.rules
    else
        echoR "Can not get the mac address of ${APDEV_NAME}"
    fi
}


usage_func()
{
    echo "./configure.sh <cmd> <target>"
    echo ""
    echo "Supported cmd:"
    echo "[ install, rename ]"
    echo ""
    echo "Supported target:"
    echo "[ dep, apDev ]"
}


[ $# -lt 2 ] && echo "Invalid args count:$# " && usage_func && exit 1

mkdir -p tmp

case $1 in
    install) echoY "Installing dependence..."
        if [ $2 == "dep" ]
        then
            sudo apt-get -y install lshw
        else
            echoR "Command install only support target dep."
        fi
        ;;
    rename) echoY "Renaming AP device name to piAPDev..."
        if [ $2 == "apDev" ]
        then
            rename_AP_device_func
        else
            echoR "Command rename only support target apDev."
        fi
        ;;
    *) echo "Unsupported cmd:$1."
        usage_func
        exit 1
esac

exit 0

