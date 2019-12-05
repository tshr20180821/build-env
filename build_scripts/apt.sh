#!/bin/bash

set -x

date

BUILD_DIR=$(pwd)

APT_OPTIONS="-o debug::nolocking=true -o dir::cache=/tmp -o dir::state=/tmp"
APT_FORCE_YES="-y --allow-downgrades --allow-remove-essential --allow-change-held-packages"

apt-get ${APT_OPTIONS} update
apt-get ${APT_OPTIONS} -s --print-uris upgrade
apt-get ${APT_OPTIONS} -s -V upgrade | grep -o -E '^   [a-zA-Z0-9].+? ' | awk '{print $1}' >/tmp/update_list

for PACKAGE in $(cat /tmp/update_list); do
  time apt-get ${APT_OPTIONS} ${APT_FORCE_YES} -s -d --print-uris install --reinstall ${PACKAGE}
done

# for DEB in $(ls -1 /tmp/archives/*.deb); do
#   time dpkg -x ${DEB} ${BUILD_DIR}/.apt/
# done

date
