#!/bin/bash

set -x

date

GIT_VERSION=2.23.0

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

export CCACHE_DIR=/tmp/ccache

export PATH="/tmp/usr/bin:${PATH}"

pushd /tmp/usr/bin
ln -s ccache gcc
ln -s ccache g++
ln -s ccache cc
ln -s ccache c++
popd

ccache -s
ccache -z

pushd /tmp
curl -L -O https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz
tar xf v${GIT_VERSION}.tar.gz
ls -lang
pushd git-${GIT_VERSION}
make configure
./configure --help
./configure --prefix /tmp/usr

time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
if [ $? != 0 ]; then
  echo 'time out'
  result='NG'
else
  result='OK'
  time make install
fi

popd
popd

ccache -s

pushd /tmp
time tar cf ccache_cache.tar.bz2 --use-compress-prog=pbzip2 ./ccache
mv ccache_cache.tar.bz2 repo/build-env/ccache/
pushd repo/build-env
git init
git config --global user.email "user"
git config --global user.name "user"
git add .
git commit -a -m "."
git remote set-url origin https://github.com/tshr20140816/build-env
git push origin master
popd
popd

tree /tmp/usr

ldd /tmp/usr/bin/git

/tmp/usr/bin/git --version

pushd ../
mkdir bin
cp /tmp/usr/bin/git ./bin/
cp /tmp/usr/bin/git ./www/
popd

date
