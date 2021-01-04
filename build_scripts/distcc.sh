  
#!/bin/bash

set -x

date

DISTCC_VERSION=3.3.5

whereis python
python --version
find / -name Python.h -print 2>/dev/null

PYTHON_H=$(pwd)/../.apt/usr/include/python3.6m/

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer -I${PYTHON_H}"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

curl -L -O https://github.com/distcc/distcc/archive/v${DISTCC_VERSION}.tar.gz

tar xf v${DISTCC_VERSION}.tar.gz

pushd distcc-${DISTCC_VERSION}
ls -lang
time sh autogen.sh
./configure --help
time ./configure --prefix=/tmp/usr
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd
popd

tree /tmp/usr

ldd /tmp/usr/bin/distcc
ldd /tmp/usr/bin/distccd
ldd /tmp/usr/bin/distccmon-text
ldd /tmp/usr/bin/lsdistcc

/tmp/usr/bin/distcc --version

cp /tmp/usr/bin/distcc ../www/
cp /tmp/usr/bin/distccd ../www/

date
