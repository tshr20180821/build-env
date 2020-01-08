#!/bin/bash

set -x

date

gcc -v --help 2>/dev/null | grep -E "^\s+\-std=.*$"

CVS_VERSION=1.11.23

# export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer -std=c99"
export CFLAGS="-std=c99 -Wimplicit-function-declaration"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

time curl -sSO https://ftp.gnu.org/non-gnu/cvs/source/stable/${CVS_VERSION}/cvs-${CVS_VERSION}.tar.bz2
tar xf cvs-${CVS_VERSION}.tar.bz2
ls -lang

pushd cvs-${CVS_VERSION}
./configure --help
time ./configure --prefix=/tmp/usr --disable-server
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd

popd

tree /tmp/usr

# ldd /tmp/usr/bin/pngquant
# /tmp/usr/bin/pngquant --version

# cp /tmp/usr/bin/pngquant ../www/
