#!/bin/bash

set -x

date

BUILD_DIR=$(pwd)

SUBVERSION_VERSION=1.13.0

ls -lang ${BUILD_DIR}/../.apt/usr/lib/x86_64-linux-gnu

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer -L${BUILD_DIR}/../.apt/usr/lib/x86_64-linux-gnu"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

time curl -O http://ftp.riken.jp/net/apache/subversion/subversion-${SUBVERSION_VERSION}.tar.bz2

tar xf subversion-${SUBVERSION_VERSION}.tar.bz2

pushd subversion-${SUBVERSION_VERSION}
./configure --help
time ./configure --prefix=/tmp/usr --enable-shared=no
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd
popd

tree /tmp/usr

ldd /tmp/usr/bin/svn
/tmp/usr/bin/svn --version

cp /tmp/usr/bin/svn ../www/
