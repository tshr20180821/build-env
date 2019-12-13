#!/bin/bash

set -x

date
       
# ***** apt *****

BUILD_DIR=$(pwd)

# ***** delegate *****

export CFLAGS="-O2 -march=native -std=gnu++98"
export CXXFLAGS="$CFLAGS"

pushd /tmp

curl -O http://delegate.hpcc.jp/anonftp/DeleGate/delegate9.9.13.tar.gz
tar xf delegate9.9.13.tar.gz

pushd delegate9.9.13

rm ./src/builtin/mssgs/news/artlistfooter.dhtml
echo "<HR>" >./src/builtin/mssgs/news/artlistfooter.dhtml

diff ${BUILD_DIR}/../files/fpoll.h include/fpoll.h
cp -f ${BUILD_DIR}/../files/fpoll.h include/

time make ADMIN="admin@localhost"

ldd ./src/delegated

popd
popd

cp /tmp/delegate9.9.13/src/delegated ../www/

date
