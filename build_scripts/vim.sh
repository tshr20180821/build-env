#!/bin/bash

set -x

date

VIM_VERSION=v8.1.2424

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold -static"

export CCACHE_DIR=/tmp/ccache_cache
mkdir ${CCACHE_DIR}
ls -lang /tmp

export PATH="/tmp/usr/bin:${PATH}"

pushd /tmp/usr/bin
ln -s ccache gcc
ln -s ccache g++
ln -s ccache cc
ln -s ccache c++
popd

ls -lang /tmp/usr/bin
ccache --version
ldd /tmp/usr/bin/ccache

ccache -s
ccache -z

pushd /tmp

time git clone --depth=1 -b ${VIM_VERSION} https://github.com/vim/vim.git

ls -lang

pushd vim

./configure --help
time ./configure --prefix=/tmp/usr --disable-darwin --enable-multibyte --disable-rightleft --disable-arabic

date

time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
if [ $? != 0 ]; then
  echo 'time out'
else
  time make install
fi

popd
popd

ccache -s

pushd /tmp
time tar cf ccache_cache.tar.bz2 --use-compress-prog=lbzip2 ./ccache_cache
mv ccache_cache.tar.bz2 repo/build-env/ccache_cache/
pushd repo/build-env
git init
git config --global user.email "user"
git config --global user.name "user"
git add .
git commit -a -m "."
git remote set-url origin https://github.com/tshr20180821/build-env
git push origin master
popd
popd

tree /tmp/usr

ldd /tmp/usr/bin/vim

/tmp/usr/bin/vim --version

cp /tmp/usr/bin/vim ../www/

date
