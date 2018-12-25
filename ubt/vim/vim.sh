#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

sudo apt-get -y update
sudo apt-get -y upgrade

install_from_repo()
{
    sudo apt-get -y install vim
}

install_from_src()
{
    sudo apt-get -y install automake autogen autoconf build-essential
    sudo apt-get -y install git wget curl tree
    sudo apt-get -y install python3-dev

    sudo apt autoremove vim

    mkdir -p /opt/github/vim
    pushd /opt/github/vim
    wget -c https://github.com/vim/vim/archive/v8.1.0329.tar.gz
    tar -zxf v8.1.0329.tar.gz
    pushd vim-8.1.0329
    ./configure --prefix=/usr/local --enable-gui=gtk2 --with-features=huge --enable-luainterp=yes --enable-mzschemeinterp --enable-perlinterp=yes --enable-pythoninterp=yes --with-python-config-dir=/usr/lib/python2.7/config-arm-linux-gnueabihf --enable-python3interp=yes --with-python3-config-dir=/usr/lib/python3.5/config-3.5m-arm-linux-gnueabihf --enable-tclinterp=yes --enable-rubyinterp=yes --enable-cscope
    make VIMRUNTIMEDIR=/usr/local/share/vim/vim81
    sudo make install
    popd
    popd
}

install_from_repo
#install_from_src

sudo apt-get -y install ctags
pushd ~/
rm -rf .vimrc vim generate.vim
popd

cp ./.vimrc* ~/

#echo "Fetch generate.vim from http://www.vim-bootstrap.com/"
#echo "mv generate.vim ~/.vimrc"

echo "exec following command manually:"
echo "vim +PlugInstall +qall"
echo "cd ~/.vim/plugged/YouCompleteMe/"
echo "python3 install.py --clang-completer --go-completer"

