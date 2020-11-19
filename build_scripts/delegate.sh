#!/bin/bash

set -x

date

BUILD_DIR=$(pwd)

# ***** apt *****

rm -f /tmp/update_list

cat /etc/apt/sources.list etc/apt.sources.list >/tmp/sources.list

APT_OPTIONS="-o debug::nolocking=true -o dir::cache=/tmp -o dir::state=/tmp -o dir::etc::sourcelist=/tmp/sources.list"
APT_FORCE_YES="-y --allow-remove-essential --allow-change-held-packages"

apt-get ${APT_OPTIONS} update
apt-get ${APT_OPTIONS} -s -V upgrade | grep -o -E '^   [a-zA-Z0-9].+? ' | awk '{print $1}' >/tmp/update_list

cat /tmp/update_list

apt-get ${APT_OPTIONS} ${APT_FORCE_YES} -d install --reinstall $(paste -s /tmp/update_list)

ls -lang /tmp/archives

for DEB in $(ls -1 /tmp/archives/*.deb); do
  dpkg -x ${DEB} ${BUILD_DIR}/.apt/
done

openssl version

# ***** delegate *****

export CFLAGS="-O2 -march=native -std=gnu++98 -Wno-narrowing -DHCASE=1"
export CXXFLAGS="$CFLAGS"

cp ../files/delegate9.9.13.tar.gz /tmp/

pushd /tmp

# curl -O http://delegate.hpcc.jp/anonftp/DeleGate/delegate9.9.13.tar.gz
tar xf delegate9.9.13.tar.gz

pushd delegate9.9.13

rm ./src/builtin/mssgs/news/artlistfooter.dhtml
echo "<HR>" >./src/builtin/mssgs/news/artlistfooter.dhtml

# diff ${BUILD_DIR}/../files/fpoll.h include/fpoll.h
# cp -f ${BUILD_DIR}/../files/fpoll.h include/
diff ${BUILD_DIR}/../files/nntp.c src/nntp.c
cp -f ${BUILD_DIR}/../files/nntp.c src/

time make ADMIN="admin@localhost"

ldd ./src/delegated

popd
popd

cp /tmp/delegate9.9.13/src/delegated ../www/

date
