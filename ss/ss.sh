#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

. ../libShell/echo_color.lib
. ../libShell/sysEnv.lib

SS_REDIR_INSTALL_PATH=${HOME}/ssredir

isCorrect="N"

ssServerIP="0.0.0.0"
ssServerPort=443
ssServerPassword="ss-redir"
ssRedirLocalPort=1080

get_ss_redir_config_args()
{
	echoY "Please input your ss server IP:"
	read ssServerIP
	echoY "Please input your ss server port:"
	read ssServerPort
	#echo "Please input your ss server password:"
	#read ssServerPassword
	echoY "Please input your ss-redir local port:"
	read ssRedirLocalPort

	echoY "Your server IP is: ${ssServerIP}"
	echoY "Your server Port is: ${ssServerPort}"
	#echo "Your server password is: ${ssServerPassword}"
	echoY "Your ss-redir local port is: ${ssRedirLocalPort}"

    isCorrect="N"
	echoY "Is it correct? [y/N]"
	read isCorrect

	if [ ${isCorrect}x = "Y"x ] || [ ${isCorrect}x = "y"x ]; then
		echoG "correct"
	else
		echoR "incorrect"
		exit 1
	fi
}

check_bbr_func()
{
    sysctl net.ipv4.tcp_available_congestion_control
    sysctl net.ipv4.tcp_congestion_control
    sysctl net.core.default_qdisc
    lsmod | grep bbr
}

build_ss_redir_configs()
{
    pushd ${SS_REDIR_INSTALL_PATH}
    rm -rf ./tmpSSConfigs
    mkdir -p ./tmpSSConfigs
    cp ./config.json ./tmpSSConfigs/

	sed -i "s/0\.0\.0\.0/${ssServerIP}/" ./tmpSSConfigs/config.json
	sed -i "s/443/${ssServerPort}/" ./tmpSSConfigs/config.json
	sed -i "s/1080/${ssRedirLocalPort}/" ./tmpSSConfigs/config.json

    echoY "=== config.json is : ==="
    cat ./tmpSSConfigs/config.json
    echoY "========================"
    echo ""
    echoY "You can change default password in in ./tmpSSConfigs/config.json tmpSSConfigs/config.json before install service"
    echo ""
    echoY "========================"
    popd
}

make_ss_configs_func()
{
    get_ss_redir_config_args
    build_ss_redir_configs
}

install_ss_service_func()
{
    pushd ${SS_REDIR_INSTALL_PATH}
    sudo mkdir -p /etc/shadowsocks-libev

    sudo cp tmpSSConfigs/config.json /etc/shadowsocks-libev/
    sudo cp shadowsocks-libev_configs/shadowsocks-libev-redir.service /lib/systemd/system/
    popd
}

uninstall_ss_service_func()
{
    disable_ss_service_func

    sudo rm -rf /etc/shadowsocks-libev_bak
    sudo mv /etc/shadowsocks-libev /etc/shadowsocks-libev_bak
}

enable_ss_service_func()
{
	sudo systemctl enable shadowsocks-libev-redir.service
	sudo systemctl start shadowsocks-libev-redir.service
}

disable_ss_service_func()
{
	sudo systemctl stop shadowsocks-libev-redir.service
	sudo systemctl disable shadowsocks-libev-redir.service
}


#if [ $UID -ne 0 ]
#then
#    echoY "Superuser privileges are required to run this script."
#    echoY "e.g. \"sudo $0\""
#    exit 1
#fi

usage_func()
{
    echoY "./ss.sh <cmd> "
    echo ""
    echoY "Supported cmd:"
    echo "[ mkcfg, install_service, uninstall_service, enable_service, disable_service, check_bbr ]"
}


[ $# -lt 1 ] && echoR "Invalid args count:$# " && usage_func && exit 1

case $1 in
	mkcfg) echoY "Make ss config files..."
            make_ss_configs_func
	;;
	install_service) echoY "Install ss-redir service..."
            install_ss_service_func
            enable_ss_service_func
	;;
	uninstall_service) echoY "Uninstall ss-redir service..."
            disable_ss_service_func
	;;
	enable_service) echoY "Enable ss-redir service..."
            enable_ss_service_func
	;;
	disable_service) echoY "Disable ss-redir service..."
            disable_ss_service_func
	;;
	check_bbr) echoY "Checking for enable bbr..."
            check_bbr_func
	;;
	*) echo "unknow cmd"
esac

