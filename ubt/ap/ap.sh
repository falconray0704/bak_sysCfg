#!/bin/bash

set -o nounset
set -o errexit


isConfigSS="N"
isConfigKCP="N"

apMac="xx:xx:xx:xx:xx:xx"
apName=wlan0
apCh=6
apSSID=piAP
apPwd=piAP

ssIP="127.0.0.1"
ssPort=9000
ssrListenPort=62586
ssEncryptMethod="aes-256-cfb"

ssTcpFast="N"
sstPort=9001

outInterface=eth0

get_args()
{
	#iw list
	#lshw -C network
	sudo lshw -C network | grep -E "-network|description|logical name|serial"
	echo "Please input your AP device Name:"
	read apName
	echo "Please input your AP Mac address:"
	read apMac
	echo "Please input your AP channel number(eg:6):"
	read apCh
	echo "Please input your AP SSID:"
	read apSSID
	echo "Please input your AP password:"
	read apPwd

	echo "Please input your ss server IP:"
	read ssIP
	echo "Please input your ss-redir local port:"
	read ssrListenPort


	echo "Your AP name is: ${apName}"
	echo "Your AP Mac address is: ${apMac}"
	echo "Your AP channel is: ${apCh}"
	echo "Your AP SSID is: ${apSSID}"
	echo "Your AP password is: ${apPwd}"

	echo "Your server IP is: ${ssIP}"
	echo "Your ss-redir local port is: ${ssrListenPort}"

	echo "Is it correct? [y/N]"
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
	cp /etc/dhcpcd.conf ./tmpConfigs/
	sed -i '$a\interface wlan0' ./tmpConfigs/dhcpcd.conf
	sed -i "s/^interface wlan0/interface ${apName}/g" ./tmpConfigs/dhcpcd.conf
	sed -i '$a\static ip_address=192\.168\.11\.1\/24' ./tmpConfigs/dhcpcd.conf
	sed -i '$a\nohook wpa_supplicant' ./tmpConfigs/dhcpcd.conf

}

hostapd_config()
{
	#cmd="s/interface/interface=${apName}"
	#echo "cmd:${cmd}"

	cp ./configs/hostapd.conf ./tmpConfigs/hostapd.conf
	sed -i "s/interface=wlan0/interface=${apName}/g" ./tmpConfigs/hostapd.conf
	sed -i "s/ssid=piAP/ssid=${apSSID}/g" ./tmpConfigs/hostapd.conf
	sed -i "s/channel=6/channel=${apCh}/g" ./tmpConfigs/hostapd.conf
	sed -i "s/wpa_passphrase=piAP/wpa_passphrase=${apPwd}/g" ./tmpConfigs/hostapd.conf

	echo "================ after config ./tmpConfigs/hostapd.conf start ============================"
	cat ./tmpConfigs/hostapd.conf
	echo "================ after config ./tmpConfigs/hostapd.conf end   ============================"

	#sudo cp ./tmpConfigs/hostapd.conf /etc/hostapd/
}

dnsmasq_config()
{
	sudo systemctl stop dnsmasq.service
	sudo systemctl disable dnsmasq.service
}

dnscrypt_proxy_config()
{
    #pushd ~/dnsCryptProxy/
    sudo cp ~/dnsCryptProxy/dnscrypt-proxy.toml ./tmpConfigs/
	sudo sed -i "s/.*listen_addresses =.*/listen_addresses = \['192.168.11.1:53', '127.0.0.1:53', '[::1]:53'\]/" ./tmpConfigs/dnscrypt-proxy.toml
    #popd
}

isc_DHCP_Server_config()
{
    cp ./configs/dhcpd.conf ./tmpConfigs/
    cp ./configs/isc-dhcp-server ./tmpConfigs/

	sed -i "s/INTERFACES=\"\"/INTERFACES=\"${apName}\"/" ./tmpConfigs/isc-dhcp-server

	echo "================ after config ./tmpConfigs/isc-dhcp-server start ============================"
	cat ./tmpConfigs/isc-dhcp-server
	echo "================ after config ./tmpConfigs/isc-dhcp-server end   ============================"
}

enable_DHCP_service()
{
    #sudo systemctl start isc-dhcp-server.service
    sudo systemctl enable isc-dhcp-server.service
}

disable_DHCP_service()
{
    sudo systemctl stop isc-dhcp-server.service
    sudo systemctl disable isc-dhcp-server.service
}

enableAP_ss_forward()
{

	sudo iptables -t nat -N SHADOWSOCKS

	sudo iptables -t nat -A SHADOWSOCKS -d ${ssIP} -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN
	sudo iptables -t nat -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN

	sudo iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-ports ${ssrListenPort}
	sudo iptables -t nat -A PREROUTING -p tcp -j SHADOWSOCKS
	sudo iptables -t nat -A OUTPUT -p tcp -j SHADOWSOCKS

}

service_AP_config()
{
	cp configs/AP.service ./tmpConfigs/
	sed -i "s/wlan0/${apName}/g" ./tmpConfigs/AP.service

	echo "==================== after config ./tmpConfigs/AP.service start ==================="
	cat ./tmpConfigs/AP.service
	echo "==================== after config ./tmpConfigs/AP.service end   ==================="
}

ss_AP_forward_startup_config()
{
	sudo lshw -C network | grep -E "-network|description|logical name|serial"

	#echo "Please input your AP device Name:"
	#read apName
	echo "Please input your output deviceName(eg:eth0):"
	read outInterface

	echo "All AP:${apName} packet will forward to: ${outInterface}"

	echo "Is it correct? [y/N]"
	read isCorrect

	if [ ${isCorrect}x = "Y"x ] || [ ${isCorrect}x = "y"x ]; then
		echo "Continue to config iptable rules...."
	else
		echo "incorrect"
		exit 1
	fi

	sudo iptables -t nat -A POSTROUTING -o ${outInterface} -j MASQUERADE
	sudo iptables -A FORWARD -i ${outInterface} -o ${apName} -m state --state RELATED,ESTABLISHED -j ACCEPT
	sudo iptables -A FORWARD -i ${apName} -o ${outInterface} -j ACCEPT

    enableAP_ss_forward

	sudo sh -c "iptables-save > ./tmpConfigs/iptables.ipv4.nat"

}

commit_all_configs()
{

	sudo cp ./tmpConfigs/dhcpcd.conf /etc/dhcpcd.conf
    sudo cp ./tmpConfigs/dhcpd.conf /etc/dhcp/dhcpd.conf

    sudo cp ./tmpConfigs/dnscrypt-proxy.toml ~/dnsCryptProxy/

	sudo cp ./tmpConfigs/hostapd.conf /etc/hostapd/
	sudo cp ./tmpConfigs/AP.service /lib/systemd/system/

	sudo cp ./tmpConfigs/iptables.ipv4.nat /etc/iptables.ipv4.nat
    sudo cp ./configs/iptables /etc/network/if-up.d/

    sudo cp ./tmpConfigs/isc-dhcp-server /etc/default/

}

enableAP_service()
{
	sudo systemctl daemon-reload
	sudo systemctl enable AP.service
}

disableAP_service()
{
	sudo systemctl disable AP.service
	sudo systemctl daemon-reload
}

remove_all_configs()
{

	sudo rm -rf /etc/hostapd/hostapd.conf
	sudo rm -rf /lib/systemd/system/AP.service

	sudo rm -rf /etc/iptables.ipv4.nat
    sudo rm -rf /etc/network/if-up.d/iptables

    pushd ~/dnsCryptProxy/
	sed -i "s/.*listen_addresses =.*/listen_addresses = \['127.0.0.1:53', '[::1]:53'\]/" ./dnscrypt-proxy.toml
    popd

	#sudo sed -i '/\[keyfile\]/d' ./tmpConfigs/NetworkManager.conf
	#sudo sed -i '/unmanaged-devices/d' ./tmpConfigs/NetworkManager.conf
	sudo sed -i '/^interface wlan.$/d' /etc/dhcpcd.conf
	sudo sed -i '/^static ip_address=192\.168\.11\.1\/24$/d' /etc/dhcpcd.conf
	sudo sed -i '/^nohook wpa_supplicant$/d' /etc/dhcpcd.conf

}

uninstall_all()
{
    disableAP_service
    disable_DHCP_service
	remove_all_configs

	echo "uninstall finished..."
	echo "press any key to reboot system"

	read rb

	sudo reboot
}

install_dependence_func()
{
	sudo apt-get update
	sudo apt-get -y install hostapd lshw
    sudo apt-get -y install isc-dhcp-server

    mkdir -p ./tmpConfigs
}

make_configs_func()
{
    mkdir -p ./tmpConfigs
    get_args
    unmanaged_devices
    hostapd_config
    #dnsmasq_config
    dnscrypt_proxy_config
    isc_DHCP_Server_config
    service_AP_config

    ss_AP_forward_startup_config
}


case $1 in
	installDep) echo "Install dependence..."
		install_dependence_func
	;;
    mkCfgs) echo "Making configs ..."
        make_configs_func
    ;;
	install) echo "Installing..."
        #mkdir -p ./tmpConfigs

		#get_args

		#unmanaged_devices
		#hostapd_config
		#dnsmasq_config
        #dnscrypt_proxy_config
        #isc_DHCP_Server_config
        #service_AP_config

        #ss_AP_forward_startup_config

		echo "Please review configuration before enable AP service."
		echo "Are those correct and reboot for continue?[y/N]:"
		read isCorrect

		if [ ${isCorrect}x = "Y"x ] || [ ${isCorrect}x = "y"x ]; then
			echo "correct"
			commit_all_configs
			enableAP_service
            enable_DHCP_service

			sudo reboot
		else
			#echo "incorrect"
			exit 1
		fi

	;;
	configIptables) echo "Configuring iptables..."
		enableAP_forward
	;;
	configAutoIptables) echo "Configuring auto iptables..."
		#sudo apt-get install iptables-persistent
		enableAP_forward_startup
	;;
	check) echo "Checking AP services..."
		ps -ef | grep -E ".*hostapd|.*dnsmasq|.*dnscrypt-proxy|.*ss-tunnel|.*chinadns|.*ss-redir|.*client_linux_amd64" | grep -v grep
	;;
	test) echo "test command..."
        #dnscrypt_proxy_config
        #exit 1
		#get_args
        apName=wlan1
		unmanaged_devices
		#echo "$apName"
		#echo "$apMac"
		#unmanaged_devices
		#hostapd_config
		#dnsmasq_config

	;;
	uninstall) echo "Uninstalling..."
		uninstall_all
	;;
	*) echo "unknow cmd"
        exit 1
esac

exit 0
