#!/bin/bash

set -x

date

APACHE_VERSION=2.4.46

# - Aptfile -

printenv | sort

BUILD_DIR=$(pwd)

# export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
cflags_option=$(cat /tmp/cflags_option)
export CFLAGS="-O2 ${cflags_option} -pipe -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

export CCACHE_DIR=/tmp/ccache_cache

export PATH="/tmp/usr/bin:${PATH}"

if [ -v TARGET_SSH_PORT ]; then
  export PARALLEL_COUNT=9
  export CCACHE_PREFIX="/tmp/bin/distcc"
else
  export PARALLEL_COUNT=2
fi

pushd /tmp/usr/bin
ln -s ccache gcc
ln -s ccache g++
ln -s ccache cc
ln -s ccache c++
popd
  
ccache -s
ccache -z

pushd /tmp

# wget https://c-ares.haxx.se/download/c-ares-1.14.0.tar.gz &
wget https://github.com/c-ares/c-ares/releases/download/cares-1_16_1/c-ares-1.16.1.tar.gz &
# wget http://www.digip.org/jansson/releases/jansson-2.11.tar.bz2 &
wget http://www.digip.org/jansson/releases/jansson-2.13.1.tar.bz2 &
wget https://github.com/nghttp2/nghttp2/releases/download/v1.32.0/nghttp2-1.32.0.tar.xz &
wget https://cmake.org/files/v3.12/cmake-3.12.0-Linux-x86_64.tar.gz &
git clone --depth 1 https://github.com/google/brotli &
wget http://ftp.jaist.ac.jp/pub/apache//apr/apr-1.6.3.tar.bz2 &
wget http://ftp.jaist.ac.jp/pub/apache//apr/apr-util-1.6.1.tar.bz2 &
wget http://ftp.jaist.ac.jp/pub/apache//httpd/httpd-2.4.34.tar.gz &

wait

# ***** c-ares *****

# 1.16.1
tar xf c-ares-1.16.1.tar.gz
target=c-ares-1.16.1
pushd ${target}

if [ -f ${BUILD_DIR}/../ccache_cache/config.cache.c-ares ]; then
  ./configure --prefix=/tmp/usr --cache-file=${BUILD_DIR}/../ccache_cache/config.cache.c-ares
else
  ./configure --prefix=/tmp/usr --config-cache
  cp ./config.cache /tmp/config.cache.c-ares
fi
time timeout -sKILL 90 make -j${PARALLEL_COUNT}
make install &

popd

# ***** jansson *****

# 2.13.1
tar xf jansson-2.13.1.tar.bz2
target=jansson-2.13.1

pushd ${target}

./configure --help
if [ -f ${BUILD_DIR}/../ccache_cache/config.cache.jansson ]; then
  ./configure --prefix=/tmp/usr --cache-file=${BUILD_DIR}/../ccache_cache/config.cache.jansson
else
  ./configure --prefix=/tmp/usr --config-cache
  cp ./config.cache /tmp/config.cache.jansson
fi
time timeout -sKILL 90 make -j${PARALLEL_COUNT}
make install &

popd

popd

ccache -s

pushd /tmp
time tar cf ccache_cache.tar.bz2 --use-compress-prog=lbzip2 ./ccache_cache
ls -lang ccache_cache.tar.bz2
mv ccache_cache.tar.bz2 repo/build-env/ccache_cache/
pushd repo/build-env
git init
git config --global user.email "user"
git config --global user.name "user"
# 1MB -> 30MB
# git config --global http.postbuffer 31457280
git add .
git commit -a -m "."
git remote set-url origin https://github.com/tshr20180821/build-env
time git push origin master
popd
popd

tree /tmp/usr

cp /tmp/config.cache.c-ares ../www/
cp /tmp/config.cache.jansson ../www/

date
