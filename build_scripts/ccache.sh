#!/bin/bash

set -x

date

# CCACHE_VERSION=3.7.12
CCACHE_VERSION=4.0

# - Aptfile -
# libzstd-dev
# libb2-dev
# gperf
echo "libzstd-dev" >/tmp/update_list
echo "libb2-dev" >>/tmp/update_list
echo "gperf" >>/tmp/update_list
bash ../apt_install.sh

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

rm /tmp/usr/bin/ccache

pushd /tmp

time git clone -b v${CCACHE_VERSION} --depth=1 https://github.com/ccache/ccache.git

pushd ccache
time sh autogen.sh
./configure --help
time ./configure --prefix=/tmp/usr --disable-man
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
popd
popd

ldd /tmp/ccache/ccache

/tmp/ccache/ccache --version

cp /tmp/ccache/ccache ../www/

date
