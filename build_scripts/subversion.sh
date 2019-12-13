#!/bin/bash

set -x

date

SUBVERSION_VERSION=1.13.0

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

time curl -O http://ftp.riken.jp/net/apache/subversion/subversion-1.13.0.tar.bz2

tar xf subversion-1.13.0.tar.bz2

pushd subversion-1.13.0
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
