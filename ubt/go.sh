#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

GOVERSION="1.12"

install_dependence_func()
{
    echo "Installing dependence..."
    sudo apt-get -y install gccgo-6
}

install_go_1_4_func()
{
    pushd ~/
    #export http_proxy=10.1.51.48:42581
    #export https_proxy=10.1.51.48:42581
    #export sock5_proxy=10.1.51.48:42581
    rm -rf go go1.4

    wget -c https://dl.google.com/go/go1.4-bootstrap-20171003.tar.gz
    tar -zxf go1.4-bootstrap-20171003.tar.gz
    mv go go1.4
    pushd ~/go1.4/src
    #sudo update-alternatives --set go /usr/bin/go-5
    GOROOT_BOOTSTRAP=/usr ./make.bash
    popd

    popd
}

install_latest_go_func()
{
    pushd ~/
    rm -rf go
    #git clone https://github.com/golang/go.git
    #wget https://storage.googleapis.com/golang/go1.8.src.tar.gz
    #wget -c https://storage.googleapis.com/golang/go1.9.1.src.tar.gz
    wget -c https://dl.google.com/go/go${GOVERSION}.src.tar.gz
    #tar -zxf go1.8.src.tar.gz
    tar -zxf go${GOVERSION}.src.tar.gz
    pushd go/src
    ./all.bash
    popd

    popd
}

case $1 in
    installGoBootStrap) echo "Installing bootstrap go1.4..."
        install_dependence_func
        install_go_1_4_func
        ;;
    install) echo "Installing Go:${GOVERSION}..."
        install_latest_go_func
        ;;
    update) echo "Updating to Go:${GOVERSION}"
        install_latest_go_func
        ;;
    *) echo "Unknow command!"
        echo "Only support following commands:"
        echo "installGoBootStrap"
        echo "install"
        echo "update"
esac

# set go env
#export GOROOT=$HOME/go
#export GOPATH=/md/gows
#export PATH=$PATH:$GOROOT/bin
#alias gw='cd $GOPATH'

