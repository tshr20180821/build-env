#!/bin/bash

set -x

date

PARALLEL_VERSION=20191022

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

export CCACHE_DIR=/tmp/ccache_cache

export PATH="/tmp/usr/bin:${PATH}"

pushd /tmp/usr/bin
ln -s ccache gcc
ln -s ccache g++
ln -s ccache cc
ln -s ccache c++
popd

ccache --version

ccache -s
ccache -z

pushd /tmp

curl -O http://ftp.gnu.org/gnu/parallel/parallel-latest.tar.bz2
ls -lang

popd

date
