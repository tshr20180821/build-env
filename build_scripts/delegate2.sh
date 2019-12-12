#!/bin/bash

set -x

date
       
# ***** apt *****

BUILD_DIR=$(pwd)

APT_OPTIONS="-o debug::nolocking=true -o dir::cache=/tmp -o dir::state=/tmp"
APT_FORCE_YES="-y --allow-remove-essential --allow-change-held-packages"

apt-get ${APT_OPTIONS} update
echo libssl hold | dpkg --set-selections
apt-get ${APT_OPTIONS} -s -V upgrade | grep -o -E '^   [a-zA-Z0-9].+? ' | awk '{print $1}' >/tmp/update_list

echo "gcc-5-i686-linux-gnu" >>/tmp/update_list

cat /tmp/update_list

time apt-get ${APT_OPTIONS} ${APT_FORCE_YES} -d install --reinstall $(paste -s /tmp/update_list)

ls -lang /tmp/archives/*.deb

for DEB in $(ls -1 /tmp/archives/*.deb); do
  dpkg -x ${DEB} ${BUILD_DIR}/../.apt/
done

# ***** delegate *****

export PATH=${BUILD_DIR}/../.apt/usr/i686-linux-gnu/bin:${PATH}

pushd ${BUILD_DIR}/../.apt/usr/i686-linux-gnu/bin
ln -s ../../bin/i686-linux-gnu-gcc-5 gcc
ln -s ../../bin/i686-linux-gnu-gcc-5 cc
ldd ld
popd

ls -lang ${BUILD_DIR}/../.apt/usr/i686-linux-gnu/bin

cc --version

export CFLAGS="-O2 -march=native"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-L/app/.apt/usr/i686-linux-gnu/lib"

pushd /tmp

curl -O http://delegate.hpcc.jp/anonftp/DeleGate/delegate9.9.13.tar.gz
tar xf delegate9.9.13.tar.gz

pushd delegate9.9.13

rm ./src/builtin/mssgs/news/artlistfooter.dhtml
echo "<HR>" >./src/builtin/mssgs/news/artlistfooter.dhtml

time make ADMIN="admin@localhost"

ldd ./src/delegated

popd
popd

cp /tmp/delegate9.9.13/src/delegated ../www/

date
