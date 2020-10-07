  
#!/bin/bash

set -x

date

BROTLI_VERSION=1.0.9

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp
curl -L -O https://github.com/google/brotli/archive/v${BROTLI_VERSION}.tar.gz
tar xf v${BROTLI_VERSION}.tar.gz
pushd brotli-${BROTLI_VERSION}
ls -lang
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
ls -lang bin
tree ./
popd
popd

ldd /tmp/brotli-${BROTLI_VERSION}/bin/brotli

/tmp/brotli-${BROTLI_VERSION}/bin/brotli --version

cp /tmp/brotli-${BROTLI_VERSION}/bin/brotli ../www/

date
