#!/bin/bash

set -x

date

LBZIP2_VERSION=v2.5

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

time git clone --recursive --depth=1 -b ${LBZIP2_VERSION} https://github.com/kjn/lbzip2.git

pushd lbzip2
autoconf
./configure --help
time ./configure --prefix=/tmp/usr
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd

popd

tree /tmp/usr

ldd /tmp/usr/bin/lbzip2
/tmp/usr/bin/lbzip2 --version

cp /tmp/usr/bin/lbzip2 ../www/
