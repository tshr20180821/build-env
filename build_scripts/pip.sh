#!/bin/bash

set -x

date

cflags_option=$(cat /tmp/cflags_option)
export CFLAGS="-O2 ${cflags_option} -pipe -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

export PYTHONUSERBASE=/tmp/python
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
time python /tmp/get-pip.py --user --no-warn-script-location

/tmp/python/bin/pip --help
/tmp/python/bin/pip install --help

time /tmp/python/bin/pip install --no-color --progress-bar=ascii -I --user bzr mercurial

pushd ${PYTHONUSERBASE}
time tar cf /tmp/pips.tar.bz2 --use-compress-prog=lbzip2 ./
popd

mv /tmp/pips.tar.bz2 ../www

date
