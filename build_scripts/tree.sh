#!/bin/bash

set -x

date

TREE_VERSION=1.8.0

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

export PATH="/tmp/usr/bin:${PATH}"

pushd /tmp

curl -O http://mama.indstate.edu/users/ice/tree/src/tree-${TREE_VERSION}.tgz
tar xf tree-${TREE_VERSION}.tgz
ls -lang
pushd tree-${TREE_VERSION}
./configure --help
time ./configure --prefix=/tmp/usr

time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
time make install
popd
popd

tree /tmp/usr

ldd /tmp/usr/bin/tree

/tmp/usr/bin/tree --version

cp /tmp/usr/bin/tree ../www/

date
