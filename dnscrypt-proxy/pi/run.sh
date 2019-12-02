#!/bin/bash

set -e
#set -x

. ../../libShell/echo_color.lib

ARCH=$(arch)

check_dns_func()
{
    ss -lp 'sport = :domain'
}

uninstall_systemDNS_func()
{
    sudo apt-get remove dnsmasq
    sudo apt-get purge dnsmasq

    sudo apt-get remove --auto-remove avahi-daemon
    sudo apt-get purge --auto-remove avahi-daemon

    sudo systemctl stop systemd-resolved.service
    sudo systemctl disable systemd-resolved.service

    # prevent /etc/resolv.conf using gateway's dns
	sudo sed -i '/^static domain_name_servers=.*/d' /etc/dhcpcd.conf
	sudo sed -i '/^#static domain_name_servers=192.168.1.1$/a\static domain_name_servers=127.0.0.1' /etc/dhcpcd.conf

}


usage_func()
{
    echo "./run.sh <cmd> <target>"
    echo ""
    echo "Supported cmd:"
    echo "[ uninstall, check ]"
    echo ""
    echo "Supported target:"
    echo "[ sysDNS ]"
}

[ $# -lt 2 ] && echo "Invalid args count:$# " && usage_func && exit 1

case $1 in
    uninstall) echoY "Uninstalling $2..."
        if [ $2 == "sysDNS" ] 
        then
            uninstall_systemDNS_func
        else
            echoR "Unknow target:$2, only support uninstalling targets [sysDNS]."
            usage_func
        fi
        ;;
    check) echoY "Checking local $2 service ..."
        if [ $2 == "sysDNS" ] 
        then
            check_dns_func
        else
            echoR "Unknow target:$2, only support checking targets [sysDNS]."
            usage_func
        fi
        ;;
    *) echo "Unsupported cmd:$1."
        usage_func
        exit 1
esac

exit 0

