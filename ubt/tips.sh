#!/bin/bash

set -o nounset
set -o errexit

#set -x

tips_compress_func()
{
    echo "[001] Compress file with multi CPU:"
    echo 'pbzip2 -kzvp4 <input file name'
    echo 'tar cf <file name>.tar.bz2 --use-compress-prog=pbzip2 <dir_to_compress>'
    echo ""
}

tips_help_func()
{
    echo "Supported tips:"
    echo '001) [compress]        Tips for compression.'
}


case $1 in
    compress) echo "001) [compression] Tips:"
        tips_compress_func
        ;;
    help|*) echo "Tips for ubuntu:"
        tips_help_func
        ;;
esac


