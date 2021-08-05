#!/bin/bash

set -x

date

XZ_VERSION=5.2.5

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
# export LDFLAGS="-fuse-ld=gold"
export LDFLAGS="-fuse-ld=gold -static"

pushd /tmp

curl -L -O https://tukaani.org/xz/xz-${XZ_VERSION}.tar.xz
ls -lang

tar xf v${XZ_VERSION}.tar.gz
pushd xz-${XZ_VERSION}
ls -lang
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
ls -lang bin
tree ./
popd
popd

ldd /tmp/xz-${XZ_VERSION}/bin/xz

/tmp/xz-${XZ_VERSION}/bin/xz --version

cp /tmp/xz-${XZ_VERSION}/bin/xz ../www/

date
