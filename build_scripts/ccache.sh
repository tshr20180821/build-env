#!/bin/bash

set -x

date

# CCACHE_VERSION=3.7.12
# CCACHE_VERSION=4.0
# CCACHE_VERSION=4.3
# CCACHE_VERSION=4.5.1
# CCACHE_VERSION=4.6
CCACHE_VERSION=4.6.1

# - Aptfile -
# libzstd-dev
# libb2-dev
# gperf
echo "libzstd-dev" >/tmp/update_list
echo "libb2-dev" >>/tmp/update_list
echo "gperf" >>/tmp/update_list
# echo "asciidoc" >>/tmp/update_list
bash ../apt_install.sh

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer -Werror=pedantic"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

rm /tmp/usr/bin/ccache

pushd /tmp

# wget https://cmake.org/files/v3.18/cmake-3.18.4-Linux-x86_64.tar.gz
# wget https://github.com/Kitware/CMake/releases/download/v3.19.6/cmake-3.19.6-Linux-x86_64.tar.gz
# wget https://github.com/Kitware/CMake/releases/download/v3.20.3/cmake-3.20.3-linux-x86_64.tar.gz
wget https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1-linux-x86_64.tar.gz
time git clone -b v${CCACHE_VERSION} --depth=1 https://github.com/ccache/ccache.git

mkdir /tmp/usr
# tar xf cmake-3.18.4-Linux-x86_64.tar.gz -C /tmp/usr --strip=1
# tar xf cmake-3.19.6-Linux-x86_64.tar.gz -C /tmp/usr --strip=1
# tar xf cmake-3.20.3-Linux-x86_64.tar.gz -C /tmp/usr --strip=1
tar xf cmake-3.22.1-linux-x86_64.tar.gz -C /tmp/usr --strip=1

export PATH="/tmp/usr/bin:${PATH}"

pushd ccache
# time sh autogen.sh
# ./configure --help
# time ./configure --prefix=/tmp/usr --disable-man
cmake --help
mkdir out
pushd out
# cmake -DCMAKE_BUILD_TYPE=Release -DZSTD_FROM_INTERNET=ON --disable-man --prefix=/tmp/usr ../
cmake -DCMAKE_BUILD_TYPE=Release -DZSTD_FROM_INTERNET=ON -DHIREDIS_FROM_INTERNET=ON -DCMAKE_INSTALL_PREFIX=/tmp/usr ../
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
# time timeout -sKILL 210 make -j1
find /tmp -name ccache -print
# make install
popd
popd
popd

ldd /tmp/ccache/ccache

/tmp/ccache/out/ccache --version

cp /tmp/ccache/out/ccache ../www/

date
