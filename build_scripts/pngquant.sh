#!/bin/bash

set -x

date

PNGQUANT_VERSION=2.12.1

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer -I${PYTHON_H}"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

curl -L -O https://github.com/kornelski/pngquant/archive/${PNGQUANT_VERSION}.tar.gz

tar xf ${PNGQUANT_VERSION}.tar.gz

pushd pngquant-${PNGQUANT_VERSION}
./configure --help
time ./configure --prefix=/tmp/usr
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd

popd

tree /tmp/usr

ldd /tmp/usr/bin/pngquant
/tmp/usr/bin/pngquant --version

cp /tmp/usr/bin/pngquant ../www/
