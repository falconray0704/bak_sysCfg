#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

isCorrect="N"

ssServerIP="127.0.0.1"
ssServerPort=8388
ssServerPassword="ss-redir"
ssRedirLocalPort=1080

get_ss_redir_config_args()
{
	echo "Please input your ss server IP:"
	read ssServerIP
	echo "Please input your ss server port:"
	read ssServerPort
	#echo "Please input your ss server password:"
	#read ssServerPassword
	echo "Please input your ss-redir local port:"
	read ssRedirLocalPort

	echo "Your server IP is: ${ssServerIP}"
	echo "Your server Port is: ${ssServerPort}"
	#echo "Your server password is: ${ssServerPassword}"
	echo "Your ss-redir local port is: ${ssRedirLocalPort}"

    isCorrect="N"
	echo "Is it correct? [y/N]"
	read isCorrect

	if [ ${isCorrect}x = "Y"x ] || [ ${isCorrect}x = "y"x ]; then
		echo "correct"
	else
		echo "incorrect"
		exit 1
	fi
}

install_dependence()
{
    echo "Installing dependence ..."
    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get -y dist-upgrade
    sudo apt-get -y install --no-install-recommends gettext build-essential autoconf libtool libpcre3-dev asciidoc xmlto libev-dev libc-ares-dev automake libmbedtls-dev libsodium-dev

}

install_mbedtls_2_6_0()
{
    # Installation of MbedTLS
    export MBEDTLS_VER=2.6.0
    rm -rf mbedtls-$MBEDTLS_VER-gpl.tgz mbedtls-$MBEDTLS_VER

    wget -c https://tls.mbed.org/download/mbedtls-$MBEDTLS_VER-gpl.tgz
    tar xvf mbedtls-$MBEDTLS_VER-gpl.tgz
    pushd mbedtls-$MBEDTLS_VER
    make SHARED=1 CFLAGS=-fPIC
    sudo make DESTDIR=/usr install
    popd
    sudo ldconfig
}

update_ss_latest()
{
	sudo apt-get -y update
	sudo apt-get -y upgrade
	sudo apt-get -y dist-upgrade

	pushd /opt/github/shadowsocks-libev
	git pull
	git submodule update --init --recursive

	./autogen.sh && ./configure && make
	sudo make install
    popd
}


check_bbr_func()
{
    sudo sysctl net.ipv4.tcp_available_congestion_control
    sudo sysctl net.ipv4.tcp_congestion_control
    sudo sysctl net.core.default_qdisc
    sudo lsmod | grep bbr
}

enable_bbr_func()
{
    sed -i '/### bbr/d' /etc/sysctl.conf
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    echo '### bbr'
    echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
    sysctl -p >/dev/null 2>&1

    sudo reboot
}

install_libsodium_1_0_16()
{
    export LIBSODIUM_VER=1.0.16
	rm -rf libsodium-$LIBSODIUM_VER.tar.gz libsodium-$LIBSODIUM_VER

    wget -c https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VER.tar.gz
    tar xvf libsodium-$LIBSODIUM_VER.tar.gz
    pushd libsodium-$LIBSODIUM_VER
    #./configure --prefix=/usr && make
	./autogen.sh
	./configure
    make -j4
    sudo make install
    popd
    sudo ldconfig
}


buildUpLatestSS()
{
    git clone https://github.com/shadowsocks/shadowsocks-libev.git
    pushd shadowsocks-libev
    git submodule update --init --recursive
    ./autogen.sh && ./configure && make
    sudo make install
    popd
}

install_ss_latest()
{
	mkdir -p /opt/github
	pushd /opt/github

    install_dependence
    install_mbedtls_2_6_0
    install_libsodium_1_0_16

    buildUpLatestSS

    popd
}

build_ss_redir_configs()
{
    sudo rm -rf tmpSSConfigs
    mkdir -p tmpSSConfigs
    cp ./shadowsocks-libev_configs/config.json ./tmpSSConfigs

	sudo sed -i "s/127\.0\.0\.1/${ssServerIP}/" ./tmpSSConfigs/config.json
	sudo sed -i "s/8388/${ssServerPort}/" ./tmpSSConfigs/config.json
	sudo sed -i "s/1080/${ssRedirLocalPort}/" ./tmpSSConfigs/config.json

    echo "=== config.json is : ==="
    cat ./tmpSSConfigs/config.json
    echo "========================"
    echo ""
    echo "You can change default password in in ./tmpSSConfigs/config.json tmpSSConfigs/config.json before install service"
    echo ""
    echo "========================"
}

make_ss_configs_func()
{
    get_ss_redir_config_args
    build_ss_redir_configs
}

install_ss_service_func()
{
    sudo mkdir -p /etc/shadowsocks-libev

    sudo cp tmpSSConfigs/config.json /etc/shadowsocks-libev/
    sudo cp shadowsocks-libev_configs/shadowsocks-libev-redir.service /lib/systemd/system/
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


if [ $UID -ne 0 ]
then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi

case $1 in
	"install") echo "Installing ss latest..."
            install_dependence
            install_ss_latest
	;;
	"make_configs") echo "Make ss config files..."
            make_ss_configs_func
	;;
	"install_service") echo "Install ss-redir service..."
            install_ss_service_func
            enable_ss_service_func
	;;
	"uninstall_service") echo "Uninstall ss-redir service..."
            disable_ss_service_func
	;;
	"enable_service") echo "Enable ss-redir service..."
            enable_ss_service_func
	;;
	"disable_service") echo "Disable ss-redir service..."
            disable_ss_service_func
	;;
	"update_latest") echo "Installing ss latest..."
            update_ss_latest
	;;
	"deploy_ss") echo "Deploy ss latest..."
            install_dependence
            install_ss_latest
            make_ss_configs_func
            install_ss_service_func
            enable_ss_service_func
	;;
	"enable_bbr") echo "Config for enable bbr..."
            enable_bbr_func
	;;
	"check_bbr") echo "Checking for enable bbr..."
            check_bbr_func
	;;
	"test") echo "Testing ..."
	;;
	*) echo "unknow cmd"
esac

