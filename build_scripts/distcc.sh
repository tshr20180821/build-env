  
#!/bin/bash

set -x

date

DISTCC_VERSION=3.3.3

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

curl -L -O https://github.com/distcc/distcc/archive/v${DISTCC_VERSION}.tar.gz

tar xf v${DISTCC_VERSION}.tar.gz

pushd distcc-${DISTCC_VERSION}
ls -lang

./configure --help
time ./configure --prefix=/tmp/usr

popd
popd

date
