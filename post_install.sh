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

if [ -f bin/ccache ]; then
  cp bin/ccache /tmp/usr/bin/
else
  cp .apt/usr/bin/ccache /tmp/usr/bin/
fi

chmod 666 /tmp/usr/bin/ccache
/tmp/usr/bin/ccache --version

mkdir /tmp/repo
pushd /tmp/repo
git clone --depth=1 https://github.com/tshr20140816/build-env.git
ls -lang
popd

mv /tmp/repo/build-env/ccache_cache/ccache_cache.tar.bz2 /tmp/
pushd /tmp
time tar xf ccache_cache.tar.bz2 --strip-components 1
rm ccache_cache.tar.bz2
popd

pushd build_scripts
chmod +x ./${BUILD_SCRIPT_NAME}.sh
./${BUILD_SCRIPT_NAME}.sh
popd

date
