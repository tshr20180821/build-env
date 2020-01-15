#!/bin/bash

set -x

date

NKF_VERSION=2.1.5

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

curl -LO https://ymu.dl.osdn.jp/nkf/70406/nkf-2.1.5.tar.gz
tar xf nkf-2.1.5.tar.gz
ls -lang
pushd nkf-${NKF_VERSION}

time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)

ls -lang

popd
popd

# ldd /tmp/usr/bin/parallel

# /tmp/usr/bin/parallel --version

# cp /tmp/usr/bin/parallel ../www/

date
