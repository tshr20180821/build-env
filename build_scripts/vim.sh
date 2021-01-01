#!/bin/bash

set -x

date

VIM_VERSION=v8.1.2424

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

time git clone --depth=1 -b ${VIM_VERSION} https://github.com/vim/vim.git

ls -lang

exit

pushd aria2-${ARIA2_VERSION}

./configure --help
time ./configure --prefix=/tmp/usr --enable-static=yes --enable-shared=no

date

time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
if [ $? != 0 ]; then
  echo 'time out'
else
  time make install
fi

popd
popd

tree /tmp/usr

ldd /tmp/usr/bin/vim

/tmp/usr/bin/vim --version

cp /tmp/usr/bin/vim ../www/

date
