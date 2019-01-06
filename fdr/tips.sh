#!/bin/bash

set -o nounset
set -o errexit

#set -x

tips_nmcli_func()
{
    echo "Refer to https://docs.fedoraproject.org/en-US/Fedora/25/html/Networking_Guide/sec-Connecting_to_a_Network_Using_nmcli.html"
    echo ""
    echo ""

    echo "[001] Show all connections:"
    echo 'nmcli connection show'
    echo ""
    echo "[002] Scan all available wifi connections:"
    echo 'sudo nmcli device wifi rescan'
    echo ""
    echo "[003] List all available wifi connections:"
    echo 'nmcli device wifi list'
    echo ""
    echo "[004] Create new wifi connection:"
    echo 'nmcli connection add ifname <device name> con-name <connection name> type wifi 802-11-wireless.ssid <wifi ssid>'
    echo ""
    echo "[005] Modify set wifi connection's security type to wpa:"
    echo 'nmcli connection modify piAP-3-3d wifi-sec.key-mgmt wpa-psk'
    echo ""
    echo "[006] Modify set wifi connection's password:"
    echo 'nmcli connection modify piAP-3-3d wifi-sec.psk <password>'
    echo ""
    echo "[007] Set wifi static connection:"
    echo 'sudo nmcli connection modify piAP-3-3d ipv4.method manual ipv4.addresses 192.168.11.11/24 ipv4.gateway 192.168.11.1 ipv4.dns 192.168.11.1'
    echo ""
    echo "[008] Wifi connection up:"
    echo 'nmcli connection up <connection name>'
    echo ""

}

tips_dnf_func()
{
    echo "[001]Check dnf version:"
    echo 'dnf --version'
    echo ""
    echo "[002]Check dnf repolist:"
    echo 'dnf repolist'
    echo 'dnf repolist all'
    echo ""
    echo "[003]Check dnf available and come from Repo packages:"
    echo 'dnf list'
    echo ""
    echo "[004]Check dnf installed packages:"
    echo 'dnf list installed'
    echo ""
    echo "[005]Check dnf available Repo packages:"
    echo 'dnf list available'
    echo ""
    echo "[006]Search dnf available Repo package:"
    echo 'dnf search <package name>'
    echo ""
    echo "[007]Get package info:"
    echo 'dnf info <package name>'
    echo ""
    echo "[007]Install dnf package :"
    echo 'dnf install <package name>'
    echo ""
    echo "[008]Update dnf package :"
    echo 'dnf update <package name>'
    echo ""
    echo "[009]Check system dnf packages update :"
    echo 'dnf check-update '
    echo ""
    echo "[010]Update all system dnf packages :"
    echo 'dnf update '
    echo 'dnf upgrade '
    echo ""
    echo "[011]Remove dnf package :"
    echo 'dnf remove <package name>'
    echo 'dnf erase <package name>'
    echo ""
    echo "[012]Remove dnf no useful package :"
    echo 'dnf autoremove'
    echo ""
    echo "[013]Remove dnf cache:"
    echo 'dnf clean all'
    echo ""
    echo "[014]Get file come from which dnf package:"
    echo 'dnf provides <package name>'
    echo 'eg: dnf provides /bin/bash'
    echo ""

}

tips_help_func()
{
    echo "Supported tips:"
    echo '001) [dnf]        Tips for "dnf".'
    echo '002) [nmcli]      Tips for "nmcli".'
}


case $1 in
    dnf) echo "001) [dnf] Tips:"
        tips_dnf_func
        ;;
    nmcli) echo "001) [nmcli] Tips:"
        tips_nmcli_func
        ;;
    help|*) echo "Tips for fedora:"
        tips_help_func
        ;;
esac


