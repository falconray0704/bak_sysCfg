#!/bin/bash
set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

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
    echo "sudo bs=4k dd if=/dev/sdz of=image-\`date +%y%m%d%k%M\`.img.raw status=progress"
}

shrink_image_func()
{
    echo "How to shrink image file:"
    echo "wget https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh"
    echo "./pishrink.sh image.img.raw image.img"
}

resize_root_func()
{
    #echo 'How to resize "/" :'
    echo 'Login as root.'
    # enlarge the 3rd partition (this example uses mmcblk0)
    echo 'growpart /dev/mmcblk0 3'
    # resize the physical volume
    echo 'pvresize /dev/mmcblk0p3'
    # extend the root filesystem to take up the space just added to the volume that it is in
    echo 'lvextend -l +100%FREE /dev/fedora/root'
    # resize root partition for the server image (which uses xfs)
    echo 'xfs_growfs -d /'

}

print_help_func()
{
    echo "Supported utils commands:"
    echo "configSwapSize"
    echo "restore"
    echo "backup"
    echo "shrink"
}

case $1 in
	configSwapSize) echo "How to configure swap size ..."
        config_swap_size_func
	;;
	restore) echo "Recovering ..."
        restore_from_image_func
	;;
	backup) echo "Backup sdcard ..."
        backup_from_sdCard_func
	;;
	shrink) echo "Shrink image ..."
        shrink_image_func
	;;
    resizeRoot) echo 'How to resize "/" :'
        resize_root_func
    ;;
	*|-h) echo "Unknow cmd"
        print_help_func
    ;;
esac

