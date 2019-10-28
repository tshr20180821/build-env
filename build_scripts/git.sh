#!/bin/bash

set -x

date

GIT_VERSION=2.23.0

pushd /tmp
curl -L -O https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz
tar xf v${GIT_VERSION}.tar.gz
ls -lang
pushd git-${GIT_VERSION}
make configure
./configure --help
time make -j2
popd
popd

date
