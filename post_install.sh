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

pushd build_scripts
chmod +x ./${BUILD_SCRIPT_NAME}.sh
./${BUILD_SCRIPT_NAME}.sh
popd

date
