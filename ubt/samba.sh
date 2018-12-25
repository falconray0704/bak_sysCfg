#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace



#[install samba server]
sudo apt-get -y install samba
#sudo vim /etc/samba/smb.conf
sudo systemctl restart smbd.service nmbd.service 
#//Mac mount: mount_smbfs //ray:ray@172.16.197.180/ums ums

