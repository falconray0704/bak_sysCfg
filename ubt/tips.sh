#!/bin/bash

set -o nounset
set -o errexit

#set -x

. ../libShell/echo_color.lib

tips_compress_func()
{
    echoC "[001] Compress file with multi CPU:"
    echo 'pbzip2 -kzvp4 <input file name'
    echo 'tar cf <file name>.tar.bz2 --use-compress-prog=pbzip2 <dir_to_compress>'
    echo ""
}

tips_curl_func()
{
    echoC "Review curl request infos:"
    echo "curl -v www.doryhub.com > /dev/null"
}

tips_sysLimit_func()
{
    echoC "(1) Changing apply to system config file:"
    echo ""
    echo "Change limitation of file opening for all processes in the system:"
    echo 'sysctl -w "fs.file-max=2000500"'
    echo ""
    echo "Change resource limitation for current shell and processes were opened in it:"
    echo "sysctl -w fs.nr_open=2000500"
    echo 'ulimit -n 2000500'
    echo ""
    echo "Change limitation of connection by iptables:"
    echo '"vim /etc/modules" add new line "nf_conntrack" and reboot system'
    echo "sysctl -w net.nf_conntrack_max=2000500"
    echo 'sysctl -w net.netfilter.nf_conntrack_max = 2000500'
    echo 'sysctl -w net.core.somaxconn = 2000500'
    echo ""
    echo "Check limitation of connection by iptables:"
    echo "wc -l /proc/net/nf_conntrack"
    echo "Check max limitation of connection by iptables:"
    echo "cat /proc/sys/net/nf_conntrack_max"

    echoC "(2) Changing apply to system temporary:"
    echo ""
    echo "Change limitation of file opening for all processes in the system:"
    echo '"vim /etc/sysctl.conf" make "fs.file-max = 2000500" , and apply it by "sysctl -w"'
    echo ""
    echo "Change resource limitation for current shell and processes were opened in it:"
    echo '"vim /etc/sysctl.conf" make "fs.nr_open = 2000500"'
    echo "and"
    echo 'vim "/etc/security/limits.conf" make following lines:'
    echo "* soft nofile 2000500"
    echo "* hard nofile 2000500"
    echo "root soft nofile 2000500"
    echo "root hard nofile 2000500"
    echo ""
    echo "Change limitation of connection by iptables:"
    echo '"vim /etc/modules" add new line "nf_conntrack" and reboot system'
    echo '"vim /etc/sysctl.conf" and make following lines"'
    echo 'net.netfilter.nf_conntrack_max = 2000500'
    echo 'net.nf_conntrack_max = 2000500'
    echo 'net.core.somaxconn = 2000500'

    echoC "(3) Optimizations of net stack for testing:"
    echo "sysctl -w fs.file-max=2000500"
    echo "sysctl -w fs.nr_open=2000500"
    echo "sysctl -w net.nf_conntrack_max=2000500"
    echo "ulimit -n 2000500"
    echo "sysctl -w net.ipv4.tcp_mem='131072  262144  524288'"
    echo "sysctl -w net.ipv4.tcp_rmem='8760  256960  4088000'"
    echo "sysctl -w net.ipv4.tcp_wmem='8760  256960  4088000'"
    echo "sysctl -w net.core.rmem_max=16384"
    echo "sysctl -w net.core.wmem_max=16384"
    echo "sysctl -w net.core.somaxconn=2048"
    echo "sysctl -w net.ipv4.tcp_max_syn_backlog=2048"
    echo "sysctl -w /proc/sys/net/core/netdev_max_backlog=2048"
    echo "sysctl -w net.ipv4.tcp_tw_recycle=1"
    echo "sysctl -w net.ipv4.tcp_tw_reuse=1"

    echoC "(4) Debug refer to:"
    echo "http://blog.kissingwolf.com/2017/09/09/net-nf-conntrack-max-%E8%AE%BE%E7%BD%AE%E5%BC%82%E5%B8%B8%E9%97%AE%E9%A2%98/"
}

tips_help_func()
{
    echoC "Supported tips:"
    echo '001) [compress]       Tips for compression.'
    echo '002) [curl]           Tips for curl.'
    echo '003) [sysLimit]       Tips for change system limitations.'
}

[ $# -lt 1 ] && tips_help_func && exit

case $1 in
    compress) echoR "001) [compression] Tips for compreession:"
        tips_compress_func
        ;;
    curl) echoR "002) [curl] Tips for curl:"
        tips_curl_func
        ;;
    sysLimit) echoR "002) [sysLimit] Tips for change system limitations:"
        tips_sysLimit_func
        ;;
    *) echo "Unknown command:"
        ;;
esac


