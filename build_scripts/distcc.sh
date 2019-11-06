  
#!/bin/bash

set -x

date

DISTCC_VERSION=3.3.3

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

curl -L -O https://github.com/distcc/distcc/archive/v3.3.3.tar.gz

tar xf v3.3.3.tar.gz
ls -lang

popd

date
