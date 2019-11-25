#!/bin/bash

# refer to:
# https://hub.docker.com/r/alexandreoda/vlc
# docker pull alexandreoda/vlc

set -e
#set -x

. ../../libShell/echo_color.lib
. ../../libShell/sysEnv.lib

TMP_DIR="tmp"

APDEV_NAME=""
APDEV_MAC="macAddr"

APOUT_NAME=""
APOUT_MAC="macAddr"

#apMac="xx:xx:xx:xx:xx:xx"
#apName=piAPDev
apCh=6
apSSID=piAP
apPwd=piAP

ssIP="127.0.0.1"
ssPort=9000
ssrListenPort=62586
ssEncryptMethod="aes-256-cfb"

ssTcpFast="N"
sstPort=9001



rename_AP_out_func()
{

    sudo lshw -C network | grep -E "-network|description|logical name|serial"
    echoY "Please input the name of device which use for AP out:"
    read APOUT_NAME
    APDEV_MAC=$(get_iether_MAC ${APOUT_NAME})
    if [ ${APOUT_MAC} ]
    then
        echo "device mac: ${APOUT_MAC}"
        cp ./cfgs/70-piAPOut_network_interfaces.rules ./${TMP_DIR}/
        sed -i "s/macAddr/${APOUT_MAC}/" ./${TMP_DIR}/70-piAPOut_network_interfaces.rules
        sudo cp ./${TMP_DIR}/70-piAPOut_network_interfaces.rules /etc/udev/rules.d/
        cat ./${TMP_DIR}/70-piAPOut_network_interfaces.rules
    else
        echoR "Can not get the mac address of ${APOUT_NAME}"
    fi
}

rename_AP_device_func()
{

    sudo lshw -C network | grep -E "-network|description|logical name|serial"
    echoY "Please input the name of device which use for AP:"
    read APDEV_NAME
    APDEV_MAC=$(get_iether_MAC ${APDEV_NAME})
    if [ ${APDEV_MAC} ]
    then
        echo "device mac: ${APDEV_MAC}"
        cp ./cfgs/70-piAPDev_network_interfaces.rules ./${TMP_DIR}/
        sed -i "s/macAddr/${APDEV_MAC}/" ./${TMP_DIR}/70-piAPDev_network_interfaces.rules
        sudo cp ./${TMP_DIR}/70-piAPDev_network_interfaces.rules /etc/udev/rules.d/
        cat ./${TMP_DIR}/70-piAPDev_network_interfaces.rules
    else
        echoR "Can not get the mac address of ${APDEV_NAME}"
    fi
}

get_args()
{
	#iw list
	#lshw -C network
    sudo lshw -C network | grep -E "-network|description|logical name|serial"
    echoY "Please input the name of device which use for AP:"
    read APDEV_NAME
    APDEV_MAC=$(get_iether_MAC ${APDEV_NAME})
    echoY "Please input the name of device which use for AP out:"
    read APOUT_NAME
    APOUT_MAC=$(get_iether_MAC ${APOUT_NAME})

	echoY "Please input your AP channel number(eg:6):"
	read apCh
	echoY "Please input your AP SSID:"
	read apSSID
	echoY "Please input your AP password:"
	read apPwd

#	echo "Please input your ss server IP:"
#	read ssIP
#	echo "Please input your ss-redir local port:"
#	read ssrListenPort


	echo "Your AP name is: ${APDEV_NAME}"
	echo "Your AP Mac address is: ${APDEV_MAC}"
	echo "Your AP out name is: ${APOUT_NAME}"
	echo "Your AP out Mac address is: ${APOUT_MAC}"
	echo "Your AP channel is: ${apCh}"
	echo "Your AP SSID is: ${apSSID}"
	echo "Your AP password is: ${apPwd}"

#	echo "Your server IP is: ${ssIP}"
#	echo "Your ss-redir local port is: ${ssrListenPort}"

	echoY "Is it correct? [y/N]"
	read isCorrect

	if [ ${isCorrect}x = "Y"x ] || [ ${isCorrect}x = "y"x ]; then
		echo "correct"
	else
		echo "incorrect"
		exit 1
	fi
}

unmanaged_devices()
{
	cp /etc/dhcpcd.conf ./${TMP_DIR}/
	sed -i '$a\interface piAPDev' ./${TMP_DIR}/dhcpcd.conf
#	sed -i "s/^interface wlan0/interface ${apName}/g" ./${TMP_DIR}/dhcpcd.conf
	sed -i '$a\static ip_address=192\.168\.11\.1\/24' ./${TMP_DIR}/dhcpcd.conf
	sed -i '$a\nohook wpa_supplicant' ./${TMP_DIR}/dhcpcd.conf

}

hostapd_config()
{
	#cmd="s/interface/interface=${apName}"
	#echo "cmd:${cmd}"

	cp ./configs/hostapd.conf ./${TMP_DIR}/hostapd.conf
	sed -i "s/interface=wlan0/interface=${APDEV_NAME}/g" ./${TMP_DIR}/hostapd.conf
	sed -i "s/ssid=piAP/ssid=${apSSID}/g" ./${TMP_DIR}/hostapd.conf
	sed -i "s/channel=6/channel=${apCh}/g" ./${TMP_DIR}/hostapd.conf
	sed -i "s/wpa_passphrase=piAP/wpa_passphrase=${apPwd}/g" ./${TMP_DIR}/hostapd.conf

	echoY "=== after config ./${TMP_DIR}/hostapd.conf start ==="
	cat ./${TMP_DIR}/hostapd.conf
	echoY "=== after config ./${TMP_DIR}/hostapd.conf end   ==="

	#sudo cp ./tmpConfigs/hostapd.conf /etc/hostapd/
}

isc_DHCP_Server_config()
{
    cp ./configs/dhcpd.conf ./${TMP_DIR}/
    cp ./configs/isc-dhcp-server ./${TMP_DIR}/

	sed -i "s/INTERFACES=\"\"/INTERFACES=\"${APDEV_NAME}\"/" ./${TMP_DIR}/isc-dhcp-server

	echoY "=== after config ./${TMP_DIR}/isc-dhcp-server start ==="
	cat ./${TMP_DIR}/isc-dhcp-server
	echoY "=== after config ./${TMP_DIR}/isc-dhcp-server end   ==="
}

service_AP_config()
{
	cp configs/AP.service ./${TMP_DIR}/
	sed -i "s/wlan0/${APDEV_NAME}/g" ./${TMP_DIR}/AP.service

	echoY "=== after config ./${TMP_DIR}/AP.service start ==="
	cat ./${TMP_DIR}/AP.service
	echoY "=== after config ./${TMP_DIR}/AP.service end   ==="
}

ss_AP_forward_startup_config()
{
	sudo lshw -C network | grep -E "-network|description|logical name|serial"

	#echo "Please input your AP device Name:"
	#read apName
#	echo "Please input your output deviceName(eg:eth0):"
#	read outInterface

	echo "All AP:${APDEV_NAME} packet will forward to: ${APOUT_NAME}"

	echo "Is it correct? [y/N]"
	read isCorrect

	if [ ${isCorrect}x = "Y"x ] || [ ${isCorrect}x = "y"x ]; then
		echo "Continue to config iptable rules...."
	else
		echo "incorrect"
		exit 1
	fi

	sudo iptables -t nat -A POSTROUTING -o ${APOUT_NAME} -j MASQUERADE
	sudo iptables -A FORWARD -i ${APOUT_NAME} -o ${APDEV_NAME} -m state --state RELATED,ESTABLISHED -j ACCEPT
	sudo iptables -A FORWARD -i ${APDEV_NAME} -o ${APOUT_NAME} -j ACCEPT

#    enableAP_ss_forward

	sudo sh -c "iptables-save > ./tmpConfigs/iptables.ipv4.nat"

}


make_configs_func()
{
#    mkdir -p ./${TMP_DIR}
    get_args
    unmanaged_devices
    hostapd_config
    isc_DHCP_Server_config
    service_AP_config

    ss_AP_forward_startup_config
}

usage_func()
{
    echo "./configure.sh <cmd> <target>"
    echo ""
    echo "Supported cmd:"
    echo "[ install, rename, mk ]"
    echo ""
    echo "Supported target:"
    echo "[ dep, apDev, apOut, cfgs ]"
}


[ $# -lt 2 ] && echo "Invalid args count:$# " && usage_func && exit 1

mkdir -p ${TMP_DIR}

case $1 in
    install) echoY "Installing dependence..."
        if [ $2 == "dep" ]
        then
            sudo apt-get -y install lshw hostapd isc-dhcp-server
        else
            echoR "Command install only support target dep."
        fi
        ;;
    rename) echoY "Renaming AP device name to piAPDev..."
        if [ $2 == "apDev" ]
        then
            rename_AP_device_func
        elif [ $2 == "apOut" ]
            rename_AP_out_func
        else
            echoR "Command rename only support targets: [ apDev, apOut ]."
        fi
        ;;
    mk) echo "Making configs ..."
        if [ $2 == "cfgs" ]
        then
            make_configs_func
        else
            echoR "Command mk only support target [ cfgs ]."
        fi
        ;;
    *) echo "Unsupported cmd:$1."
        usage_func
        exit 1
esac

exit 0

