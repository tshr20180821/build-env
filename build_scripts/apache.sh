#!/bin/bash

set -x

date

APACHE_VERSION=2.4.51

# - Aptfile -
echo "libbrotli-dev" >>/tmp/update_list

bash ../apt_install.sh

printenv | sort

BUILD_DIR=$(pwd)

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

wget https://ftp.jaist.ac.jp/pub/apache//httpd/httpd-${APACHE_VERSION}.tar.bz2

tar xf httpd-${APACHE_VERSION}.tar.bz2
target=httpd-${APACHE_VERSION}
pushd ${target}
./configure --help
./configure --prefix=/tmp/usr \
  --enable-mods-shared="few" \
  --enable-brotli --enable-file-cache \
  --disable-authn-core --disable-authn-file --disable-access-compat --disable-authn-core \
  --disable-authz-core --disable-authz-host --disable-authz-user --disable-authz-groupfile --disable-auth-basic \
  --disable-autoindex --disable-alias --disable-dir --disable-env --disable-filter --disable-headers \
  --disable-log_config --disable-mime --disable-reqtimeout --disable-setenvif --disable-status --disable-unixd --disable-version
time timeout -sKILL 90 make -j${PARALLEL_COUNT}
make install

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
# time git push origin master
popd
popd

ls -lang /tmp/usr/modules

cp /tmp/usr/modules/mod_brotli.so ../www/
cp /tmp/usr/modules/mod_file_cache.so ../www/
