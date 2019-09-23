#!/bin/bash
set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

. ../libShell/echo_color.lib

config_swap_size_func()
{
    echo "How to configure system swap size:"
    echo "sudo vim /etc/dphys-swapfile"
}

restore_from_image_func()
{
    echo "How to restore:"
    echo "sudo umount /dev/disk1 /dev/disk2"
    echo "sudo dd bs=4k if=image.img of=/dev/disk status=progress"
}

backup_from_sdCard_func()
{
    echo "How to backup:"
    echo "sudo fdisk -l"
    echo "sudo bs=4k dd if=/dev/sdz of=image-\`date +%d%m%y\`.img status=progress"
}

shrink_image_func()
{
    echo "How to shrink image file:"
    echo "wget https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh"
    echo "./pishrink.sh image.img"
}

print_help_func()
{
    echoY "Supported utils commands:"
    echoY "configSwapSize"
    echoY "restore"
    echoY "backup"
    echoY "shrink"
}

[ $# -lt 1 ] && print_help_func && exit 1

case $1 in
	"configSwapSize") echoY "How to configure swap size ..."
        config_swap_size_func
	;;
	"restore") echoY "Recovering ..."
        restore_from_image_func
	;;
	"backup") echoY "Backup sdcard ..."
        backup_from_sdCard_func
	;;
	"shrink") echoY "Shrink image ..."
        shrink_image_func
	;;
	*|-h) echoR "Unknow cmd: $1"
        print_help_func
    ;;
esac

