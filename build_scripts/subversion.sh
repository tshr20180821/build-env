#!/bin/bash

set -x

date

SUBVERSION_VERSION=1.14.2

# - Aptfile -
# libsqlite3-dev
# libutf8proc-dev

BUILD_DIR=$(pwd)

find / -name libsqlite3.so -print 2>/dev/null
# find / -name libsqlite3.so.0.8.6 -print 2>/dev/null

# rm ${BUILD_DIR}/../.apt/usr/lib/x86_64-linux-gnu/libsqlite3.so
# pushd ${BUILD_DIR}/../.apt/usr/lib/x86_64-linux-gnu
# ln -s /usr/lib/x86_64-linux-gnu/libsqlite3.so.0.8.6 libsqlite3.so
# popd

ls -lang ${BUILD_DIR}/../.apt/usr/lib/x86_64-linux-gnu

# export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
cflags_option=$(cat /tmp/cflags_option)
# export CFLAGS="-O2 ${cflags_option} -pipe -fomit-frame-pointer"
export CFLAGS="-O2 ${cflags_option} -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"
# export LD_LIBRARY_PATH="{BUILD_DIR}/../.apt/usr/lib/x86_64-linux-gnu"

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

time curl -O http://ftp.riken.jp/net/apache/subversion/subversion-${SUBVERSION_VERSION}.tar.bz2

tar xf subversion-${SUBVERSION_VERSION}.tar.bz2

pushd subversion-${SUBVERSION_VERSION}
curl -o sqlite-amalgamation.zip https://www.sqlite.org/2015/sqlite-amalgamation-3081101.zip
unzip sqlite-amalgamation.zip
ls -lang
./configure --help
time timeout -sKILL 60 ./configure --prefix=/tmp/usr --enable-shared=no
# time timeout -sKILL 240 make -j${PARALLEL_COUNT}
time timeout -sKILL 220 make -j${PARALLEL_COUNT}
# time make install
popd
popd

ccache -s

pushd /tmp
time tar cf ccache_cache.tar.bz2 --use-compress-prog=lbzip2 ./ccache_cache
ls -lang ccache_cache.tar.bz2
mv ccache_cache.tar.bz2 repo/build-env/ccache_cache/
pushd repo/build-env
git init
git config --global user.email "user"
git config --global user.name "user"
# 1MB -> 30MB
git config --global http.postbuffer 31457280
git add .
git commit -a -m "."
git remote set-url origin https://github.com/tshr20180821/build-env
time git push origin master
popd
popd

tree /tmp/usr

ldd /tmp/usr/bin/svn
/tmp/usr/bin/svn --version

cp /tmp/usr/bin/svn ../www/
