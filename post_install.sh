#!/bin/bash

set -x

date

chmod +x ./start_web.sh

GITHUB_USER_DECODE=$(echo -n ${GITHUB_USER} | base64 -d)
GITHUB_PASSWORD_DECODE=$(echo -n ${GITHUB_PASSWORD} | base64 -d)

cat << __HEREDOC__ >> /app/.netrc
machine github.com
  login ${GITHUB_USER_DECODE}
  password ${GITHUB_PASSWORD_DECODE}
__HEREDOC__

cat /app/.netrc

mkdir -p /tmp/usr/bin

cp .apt/usr/bin/ccache /tmp/usr/bin/

mkdir /tmp/repo
pushd /tmp/repo
git clone --depth=1 https://github.com/tshr20140816/build-env.git
ls -lang
popd

mv /tmp/repo/build-env/ccache/ccache_cache.tar.bz2 /tmp/
pushd /tmp
time tar xf ccache_cache.tar.bz2 --strip-components 1
rm ccache_cache.tar.bz2
popd

ccache --version

pushd build_scripts
chmod +x ./${BUILD_SCRIPT_NAME}.sh
./${BUILD_SCRIPT_NAME}.sh
popd

date
