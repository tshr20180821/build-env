#!/bin/bash

set -x

date

# ARIA2_VERSION=1.35.0
ARIA2_VERSION=1.36.0

# - Aptfile -
# libssh2-1-dev
# libc-ares-dev
echo "libssh2-1-dev" >/tmp/update_list
echo "libc-ares-dev" >>/tmp/update_list
bash ../apt_install.sh

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

export CCACHE_DIR=/tmp/ccache_cache
mkdir ${CCACHE_DIR}
ls -lang /tmp

export PATH="/tmp/usr/bin:${PATH}"

pushd /tmp/usr/bin
ln -s ccache gcc
ln -s ccache g++
ln -s ccache cc
ln -s ccache c++
popd

ls -lang /tmp/usr/bin
ccache --version
ldd /tmp/usr/bin/ccache

ccache -s
ccache -z

pushd /tmp

curl -L -O https://github.com/aria2/aria2/releases/download/release-${ARIA2_VERSION}/aria2-${ARIA2_VERSION}.tar.xz

tar xf aria2-${ARIA2_VERSION}.tar.xz
pushd aria2-${ARIA2_VERSION}

./configure --help
time ./configure --prefix=/tmp/usr --enable-static=yes --enable-shared=no

date

time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
if [ $? != 0 ]; then
  echo 'time out'
else
  time make install
fi

popd
popd

ccache -s

pushd /tmp
time tar cf ccache_cache.tar.bz2 --use-compress-prog=lbzip2 ./ccache_cache
mv ccache_cache.tar.bz2 repo/build-env/ccache_cache/
pushd repo/build-env
git init
git config --global user.email "user"
git config --global user.name "user"
git add .
git commit -a -m "."
git remote set-url origin https://github.com/tshr20180821/build-env
git push origin master
popd
popd

tree /tmp/usr

ldd /tmp/usr/bin/aria2c

/tmp/usr/bin/aria2c --version

cp /tmp/usr/bin/aria2c ../www/

date
