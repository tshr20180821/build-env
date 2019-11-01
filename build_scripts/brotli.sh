  
#!/bin/bash

set -x

date

BROTLI_VERSION=1.0.7

pushd /tmp
curl -L -O https://github.com/google/brotli/archive/v${BROTLI_VERSION}.tar.gz
tar xf v${BROTLI_VERSION}.tar.gz
pushd brotli-${BROTLI_VERSION}
ls -lang
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
ls -lang bin
popd
popd
