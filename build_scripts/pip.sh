#!/bin/bash

set -x

date

cflags_option=$(cat /tmp/cflags_option)
export CFLAGS="-O2 ${cflags_option} -pipe -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

export MAKEFLAGS="-j2"

export PYTHONUSERBASE=/tmp/python
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
time python /tmp/get-pip.py --user --no-warn-script-location

/tmp/python/bin/pip --help
/tmp/python/bin/pip install --help

# time /tmp/python/bin/pip install -I --user bzr mercurial
time /tmp/python/bin/pip install --no-color --progress-bar=ascii -I --user bzr

pushd ${PYTHONUSERBASE}
tar cJf /tmp/pips.tar.xz ./
popd

date
