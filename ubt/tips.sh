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

tips_help_func()
{
    echoC "Supported tips:"
    echo '001) [compress]       Tips for compression.'
    echo '002) [curl]           Tips for curl.'
}

[ $# -lt 1 ] && tips_help_func && exit

case $1 in
    compress) echoR "001) [compression] Tips for compreession:"
        tips_compress_func
        ;;
    curl) echoR "002) [curl] Tips for curl:"
        tips_curl_func
        ;;
    *) echo "Unknown command:"
        ;;
esac


