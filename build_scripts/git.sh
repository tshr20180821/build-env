#!/bin/bash

set -x

date

GIT_VERSION=v2.23.0

pushd /tmp
curl -O https://github.com/git/git/archive/${GIT_VERSION}.tar.gz
tar xf v2.23.0.tar.gz
ls -lang

popd

date
