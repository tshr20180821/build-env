#!/bin/bash

set -x

date

GIT_VERSION=2.23.0

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

export CCACHE_DIR=/tmp/ccache

pushd /tmp/usr/bin
ln -s ccache gcc
ln -s ccache g++
ln -s ccache cc
ln -s ccache c++
popd

ccache -s
ccache -z

pushd /tmp
curl -L -O https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz
tar xf v${GIT_VERSION}.tar.gz
ls -lang
pushd git-${GIT_VERSION}
make configure
./configure --help
./configure --prefix /tmp/usr
time timeout -sKILL 240 make -j2
make install
popd
popd

tree /tmp/usr

ldd /tmp/usr/bin/git

/tmp/usr/bin/git --version

pushd ../
mkdir bin
cp /tmp/usr/bin/git ./bin/
cp /tmp/usr/bin/git ./www/
popd

date
