#!/bin/bash

set -x

date

TREE_VERSION=1.8.0

# export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
# export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

export PATH="/tmp/usr/bin:${PATH}"

pushd /tmp

curl -O http://mama.indstate.edu/users/ice/tree/src/tree-${TREE_VERSION}.tgz
tar xf tree-${TREE_VERSION}.tgz
pushd tree-${TREE_VERSION}

time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
popd
popd

ldd /tmp/tree-${TREE_VERSION}/tree

/tmp/tree-${TREE_VERSION}/tree --version

cp /tmp/tree-${TREE_VERSION}/tree ../www/

date
