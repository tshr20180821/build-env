#!/bin/bash

set -x

date

CCACHE_VERSION=3.7.5

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

time git clone -b v${CCACHE_VERSION} --depth=1 https://github.com/ccache/ccache.git

pushd ccache
time sh autogen.sh
./configure --help
time ./configure --prefix=/tmp/usr
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd
popd

tree /tmp/usr

ldd /tmp/usr/bin/ccache

/tmp/usr/bin/ccache --version

cp /tmp/usr/bin/ccache ../www/

date
