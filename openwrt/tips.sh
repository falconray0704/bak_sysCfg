#!/bin/bash

set -o nounset
set -o errexit

#set -x

. ../libShell/echo_color.lib

enable_ssl_on_opkg()
{
    echo "refer to: https://www.leowkahman.com/2016/04/10/use-ssl-openwrt-opkg/"
    echo "opkg update"
    echo "opkg install wget"
    echo "opkg install ca-certificates"
    echo "opkg install libustream-openssl"
    echo 'Replace all http:// URLs to https:// in /etc/opkg/distfeeds.conf'
    echo "opkg update"
}

tips_opkg_func()
{
    echo ""
    echoG "Update packages list:"
    echo "opkg update"
    echo ""
    echoG "Enable ssl on opkg after init install OS:"
    enable_ssl_on_opkg

}

tips_help_func()
{
    echo "Supported tips:"
    echo '001) [opkg] Tips for opkg command.'
}

[ $# -lt 1 ] && tips_help_func && exit

case $1 in
    help) echo "Tips for docker manipulations:"
        tips_help_func
        ;;
    opkg) echo "001) Tips for opkg command:"
        tips_opkg_func
        ;;
    *) echo "Unknown cmd: $1"
esac


