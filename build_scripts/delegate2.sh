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

# echo "gcc-4.8" >>/tmp/update_list
# echo "g++-4.8" >>/tmp/update_list
# echo "gcc-5" >>/tmp/update_list
# echo "g++-5" >>/tmp/update_list
echo "gcc-8" >>/tmp/update_list
echo "g++-8" >>/tmp/update_list

cat /tmp/update_list

time apt-get ${APT_OPTIONS} ${APT_FORCE_YES} -d install --reinstall $(paste -s /tmp/update_list)

ls -lang /tmp/archives/*.deb

for DEB in $(ls -1 /tmp/archives/*.deb); do
  dpkg -x ${DEB} ${BUILD_DIR}/../.apt/
done

# ***** delegate *****

export CFLAGS="-O2 -march=native"
export CXXFLAGS="$CFLAGS"

pushd /tmp

curl -O http://delegate.hpcc.jp/anonftp/DeleGate/delegate9.9.13.tar.gz
tar xf delegate9.9.13.tar.gz

pushd delegate9.9.13

rm ./src/builtin/mssgs/news/artlistfooter.dhtml
echo "<HR>" >./src/builtin/mssgs/news/artlistfooter.dhtml

# time make ADMIN="admin@localhost" CC=gcc-4.8 CXX=g++-4.8
# time make ADMIN="admin@localhost" CC=gcc-5 CXX=g++-5
time make ADMIN="admin@localhost" CC=gcc-8 CXX=g++-8

ldd ./src/delegated

popd
popd

cp /tmp/delegate9.9.13/src/delegated ../www/

date
