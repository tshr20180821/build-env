#!/bin/bash

set -x

date

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

export PYTHONUSERBASE=/tmp/python
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
time python /tmp/get-pip.py --user --no-warn-script-location

/tmp/python/bin/pip --help
/tmp/python/bin/pip install --help

# time /tmp/python/bin/pip install -I --user bzr mercurial
time /tmp/python/bin/pip install --no-color --progress-bar=ascii -I --user bzr

ccache -s

pushd ${PYTHONUSERBASE}
time tar cJf /tmp/pips.tar.xz ./
popd

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

date
