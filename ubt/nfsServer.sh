#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

#[install nfs server]
sudo apt-get -y install nfs-kernel-server
#sudo vim /etc/exports
#/opt/ums    *(rw,sync,no_root_squash,no_subtree_check)
sudo systemctl start nfs-kernel-server.service
#//linux fstab mount: 
#172.16.231.1:/mnt/ld0/github/falcon       /opt/github/falcon nfs defaults 0 0
#//Mac mount: sudo mount -t nfs -o rw,resvport 172.16.197.180:/opt/ums ums

