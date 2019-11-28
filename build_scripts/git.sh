#!/bin/bash

set -x

date

whereis curl
pkg-config --static --libs libcurl

pushd ..
ln -s $(pwd)/.apt /tmp/.apt
popd

GIT_VERSION=2.23.0

cflags_option=$(cat /tmp/cflags_option)
# export CFLAGS="-O2 ${cflags_option} -pipe -fomit-frame-pointer -static"
export CFLAGS="-O2 ${cflags_option} -pipe -fomit-frame-pointer `pkg-config --static --libs libcurl`"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

export CCACHE_DIR=/tmp/ccache_cache

export PATH="/tmp/usr/bin:${PATH}"

if [ -v TARGET_SSH_PORT ]; then
  export PARALLEL_COUNT=9
  export CCACHE_PREFIX="/tmp/bin/distcc"
else
  export PARALLEL_COUNT=2
fi

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
tree /tmp/.apt/usr
./configure --prefix /tmp/usr --with-curl=/tmp/.apt/usr

time timeout -sKILL 210 make -j${PARALLEL_COUNT}
if [ $? != 0 ]; then
  echo 'time out'
else
  tree ./
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
git remote set-url origin https://github.com/tshr20140816/build-env
git push origin master
popd
popd

tree /app

ldd /app/bin/git

/app/bin/git --version

cp /app/bin/git ../www/

date
