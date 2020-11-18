#!/bin/bash

set -x

date

CURL_VERSION=7.73.0
# 7.73.0 - --without-zstd

# - Aptfile -
# libssh2-1-dev
# libbrotli-dev
# libnghttp2-14
# libnghttp2-dev
# libpsl5
# libpsl-dev
# libzstd-dev
echo "libssh2-1-dev" >/tmp/update_list
echo "libbrotli-dev" >>/tmp/update_list
echo "libnghttp2-14" >>/tmp/update_list
echo "libnghttp2-dev" >>/tmp/update_list
echo "libpsl5" >>/tmp/update_list
echo "libpsl-dev" >>/tmp/update_list
echo "libzstd-dev" >>/tmp/update_list
bash ../apt_install.sh

printenv | sort

# export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
cflags_option=$(cat /tmp/cflags_option)
export CFLAGS="-O2 ${cflags_option} -pipe -fomit-frame-pointer"
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

time git clone --depth=1 -b release-0.1.3 https://github.com/metalink-dev/libmetalink.git
pushd libmetalink
time ./buildconf
./configure --help
time ./configure --prefix=/tmp/usr --enable-shared=no
# time make -j2
time make -j${PARALLEL_COUNT}
make install
popd

curl -O https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.xz
tar xf curl-${CURL_VERSION}.tar.xz
pushd curl-${CURL_VERSION}
./configure --help
./configure --prefix=/tmp/usr --enable-shared=no --enable-static=yes \
  --with-libssh2 --with-brotli --with-nghttp2 \
  --with-gssapi --with-libmetalink=/tmp/usr --enable-alt-svc --without-zstd

cat Makefile

# time timeout -sKILL 210 make
# time timeout -sKILL 180 make -j${PARALLEL_COUNT}
time timeout -sKILL 180 make -j2
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
ls -lang ccache_cache.tar.bz2
mv ccache_cache.tar.bz2 repo/build-env/ccache_cache/
pushd repo/build-env
git init
git config --global user.email "user"
git config --global user.name "user"
# 1MB -> 30MB
# git config --global http.postbuffer 31457280
git add .
git commit -a -m "."
git remote set-url origin https://github.com/tshr20180821/build-env
time git push origin master
popd
popd

tree /tmp/usr

ldd /tmp/usr/bin/curl

/tmp/usr/bin/curl --version

cp /tmp/usr/bin/curl ../www/

date
