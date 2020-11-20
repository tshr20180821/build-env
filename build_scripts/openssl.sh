#!/bin/bash

set -x

date

export CCACHE_DIR=/tmp/ccache_cache

export PATH="/tmp/usr/bin:${PATH}"

pushd /tmp/usr/bin
ln -s ccache gcc
ln -s ccache g++
ln -s ccache cc
ln -s ccache c++
popd
  
ccache -s
ccache -z

pushd /tmp

time git clone --depth=1 -b OpenSSL_1_0_2u https://github.com/openssl/openssl.git

pushd openssl
# time ./config -fPIC shared
./config --prefix=/tmp/usr shared

time timeout -sKILL 180 make -j2
make install

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

# tree /tmp/usr

# strings /tmp/usr/lib/libcrypto.so.1.0.0
strings /tmp/usr/lib/libssl.so.1.0.0 | grep OpenSSL

pwd

cp /tmp/usr/lib/libcrypto.so.1.0.0 ../wwww
cp /tmp/usr/lib/libssl.so.1.0.0 ../wwww
