#!/bin/bash

set -x

date

python --version
python3 --version

find / -name Python.h -print

cflags_option=$(cat /tmp/cflags_option)
export CFLAGS="-O2 ${cflags_option} -pipe -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

export PYTHONUSERBASE=/tmp/python
export PATH=${PYTHONUSERBASE}/bin:${PATH}
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
# time python /tmp/get-pip.py --user
time python3 /tmp/get-pip.py --user

pip --help
pip install --help

# time /tmp/python/bin/pip install -v --no-color --progress-bar=ascii -I --user bzr mercurial
# time /tmp/python/bin/pip install -v --no-color --progress-bar=ascii -I --user bzr
time /tmp/python/bin/pip install -v --no-color --progress-bar=ascii -I --user mercurial

pip freeze

pushd ${PYTHONUSERBASE}
time tar cf /tmp/pips.tar.bz2 --use-compress-prog=lbzip2 ./
popd

mv /tmp/pips.tar.bz2 ../www

date
