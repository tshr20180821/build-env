#!/bin/bash

set -x

date

MEGATOOLS_VERSION=1.10.2

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

curl -O https://megatools.megous.com/builds/megatools-${MEGATOOLS_VERSION}.tar.gz
tar xf megatools-${MEGATOOLS_VERSION}.tar.gz
ls -lang

pushd megatools-${MEGATOOLS_VERSION}
./configure --help
./configure --prefix=/tmp/usr --disable-docs
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd
popd

tree /tmp/usr

date
