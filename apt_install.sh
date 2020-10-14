#!/bin/bash

set -x

date -d '9 hours'

if [ ! -f /tmp/update_list ]; then
  exit
fi

BUILD_DIR=$(pwd)

tree /etc/apt/sources.list.d

cat /etc/apt/sources.list etc/apt.sources.list >/tmp/sources.list
cat /tmp/sources.list

APT_OPTIONS="-o debug::nolocking=true -o dir::cache=/tmp -o dir::state=/tmp -o dir::etc::sourcelist=/tmp/sources.list"
APT_FORCE_YES="-y --allow-remove-essential --allow-change-held-packages"

apt-get ${APT_OPTIONS} update
apt-get ${APT_OPTIONS} -s -V upgrade | grep -o -E '^   [a-zA-Z0-9].+? ' | awk '{print $1}' >/tmp/update_list

cat /tmp/update_list

apt-get ${APT_OPTIONS} ${APT_FORCE_YES} -d install --reinstall $(paste -s /tmp/update_list)

ls -lang /tmp/archives

ls -1 /tmp/archives/*.deb

find /tmp/archives -name "*.deb" -type f -print0 | \
  xargs --max-procs=1 --max-args=1 --null -I{} --verbose dpkg -x {} ${BUILD_DIR}/../.apt/
