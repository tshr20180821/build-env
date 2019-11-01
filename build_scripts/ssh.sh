#!/bin/bash

set -x

date

SSH_VERSION=8_1_P1

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

curl -L -O https://github.com/openssh/openssh-portable/archive/V_${SSH_VERSION}.tar.gz
tar xf V_${SSH_VERSION}.tar.gz
pushd openssh-portable-V_${SSH_VERSION}
ls -lang
autoreconf
./configure --help
./configure --prefix=/tmp/usr
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
ls -lang
popd
popd

date
