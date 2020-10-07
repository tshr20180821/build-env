  
#!/bin/bash

set -x

date

BROTLI_VERSION=1.0.9

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

curl -L -O https://cmake.org/files/v3.12/cmake-3.12.0-Linux-x86_64.tar.gz
mkdir usr
tar xf cmake-3.12.0-Linux-x86_64.tar.gz -C ./usr --strip=1
# tree ./usr
export PATH="/tmp/usr/bin:${PATH}"

curl -L -O https://github.com/google/brotli/archive/v${BROTLI_VERSION}.tar.gz
tar xf v${BROTLI_VERSION}.tar.gz
pushd brotli-${BROTLI_VERSION}
ls -lang
mkdir out
pushd out
../configure-cmake --help
../configure-cmake --prefix=/tmp/usr --disable-debug
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
popd
# time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
ls -lang bin
tree ./
popd
popd

ldd /tmp/brotli-${BROTLI_VERSION}/bin/brotli

/tmp/brotli-${BROTLI_VERSION}/bin/brotli --version

cp /tmp/brotli-${BROTLI_VERSION}/bin/brotli ../www/

date
