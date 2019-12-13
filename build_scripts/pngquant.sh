#!/bin/bash

set -x

date

PNGQUANT_VERSION=2.12.1

# export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
# export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

time git clone --recursive --depth=1 -b ${PNGQUANT_VERSION} https://github.com/kornelski/pngquant.git

pushd pngquant
./configure --help
time ./configure --prefix=/tmp/usr --with-openmp=static
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd

popd

tree /tmp/usr

ldd /tmp/usr/bin/pngquant
/tmp/usr/bin/pngquant --version

cp /tmp/usr/bin/pngquant ../www/
