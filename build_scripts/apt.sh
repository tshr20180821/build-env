#!/bin/bash

set -x

date

BUILD_DIR=$(pwd)

APT_OPTIONS="-o debug::nolocking=true -o dir::cache=/tmp -o dir::state=/tmp"
APT_FORCE_YES="-y --allow-remove-essential --allow-change-held-packages"

apt-get ${APT_OPTIONS} update
apt-get ${APT_OPTIONS} -s -V upgrade | grep -o -E '^   [a-zA-Z0-9].+? ' | awk '{print $1}' >/tmp/update_list

cat /tmp/update_list

time apt-get ${APT_OPTIONS} ${APT_FORCE_YES} -d install --reinstall $(paste -s /tmp/update_list)

# for PACKAGE in $(cat /tmp/update_list); do
#   time apt-get ${APT_OPTIONS} ${APT_FORCE_YES} -d install --reinstall ${PACKAGE}
# #   time apt-get ${APT_OPTIONS} ${APT_FORCE_YES} install --reinstall --print-uris -qq ${PACKAGE}
# #   # time apt-get ${APT_OPTIONS} ${APT_FORCE_YES} install --reinstall --print-uris ${PACKAGE}
# done

ls -lang /tmp/archives/*.deb

for DEB in $(ls -1 /tmp/archives/*.deb); do
  time dpkg -x ${DEB} ${BUILD_DIR}/.apt/
done

date
