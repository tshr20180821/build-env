#!/bin/bash

set -x

date

find / -name Python.h -print 2>/dev/null

mkdir -m 777 -p /tmp/usr/include
cp -r ${pwd}../.apt/usr/include/python3.6m /tmp/usr/include/
tree /tmp/usr/include/

cflags_option=$(cat /tmp/cflags_option)
export CFLAGS="-O2 ${cflags_option} -pipe -fomit-frame-pointer -I/tmp/usr/include -I/tmp/usr -I/tmp/usr/include/python3.6m"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"


export PYTHONUSERBASE=/tmp/python
export PATH=${PYTHONUSERBASE}/bin:${PATH}
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
time python3.6 /tmp/get-pip.py --user

# pip --help
# pip install --help

# time /tmp/python/bin/pip install --no-color --progress-bar=ascii -I --user bzr mercurial
time /tmp/python/bin/pip install -I --user bzr
time /tmp/python/bin/pip install -I --user mercurial

pip freeze

pushd ${PYTHONUSERBASE}
time tar cf /tmp/pips.tar.bz2 --use-compress-prog=lbzip2 ./
popd

mv /tmp/pips.tar.bz2 ../www

date
