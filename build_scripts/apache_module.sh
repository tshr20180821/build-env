#!/bin/bash

set -x

date

APACHE_VERSION=2.4.46

# - Aptfile -

printenv | sort

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

wget https://c-ares.haxx.se/download/c-ares-1.14.0.tar.gz &
wget http://www.digip.org/jansson/releases/jansson-2.11.tar.bz2 &
wget https://github.com/nghttp2/nghttp2/releases/download/v1.32.0/nghttp2-1.32.0.tar.xz &
wget https://cmake.org/files/v3.12/cmake-3.12.0-Linux-x86_64.tar.gz &
git clone --depth 1 https://github.com/google/brotli &
wget http://ftp.jaist.ac.jp/pub/apache//apr/apr-1.6.3.tar.bz2 &
wget http://ftp.jaist.ac.jp/pub/apache//apr/apr-util-1.6.1.tar.bz2 &
wget http://ftp.jaist.ac.jp/pub/apache//httpd/httpd-2.4.34.tar.gz &

wait

# ***** c-ares *****

tar xf c-ares-1.14.0.tar.gz
target=c-ares-1.14.0
pushd ${target}

./configure --prefix=/tmp/usr --config-cache
# time timeout -sKILL 180 make -j${PARALLEL_COUNT}
# make install

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

# ldd /tmp/usr/bin/curl

# /tmp/usr/bin/curl --version

# cp /tmp/usr/bin/curl ../www/

date
