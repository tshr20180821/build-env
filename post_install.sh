#!/bin/bash

set -x

date

chmod +x ./start_web.sh

curl -s https://${DISTCC_HOST_NAME}.herokuapp.com/ >/dev/null

ss -ant

# ***** env *****

echo 'Processor Count : ' $(grep -c -e processor /proc/cpuinfo)
cat /proc/cpuinfo | head -n $(($(cat /proc/cpuinfo | wc -l) / $(grep -c -e processor /proc/cpuinfo)))

cat /proc/version

whereis gcc
gcc --version
ldd /usr/bin/gcc

# ***** heroku cli *****

mkdir heroku
curl -sS -o heroku/heroku.tar.gz https://cli-assets.heroku.com/heroku-cli/channels/stable/heroku-cli-linux-x64.tar.gz

pushd heroku
tar xf heroku.tar.gz --strip-components=1
rm heroku.tar.gz
pushd bin
time ./heroku update
popd
popd

# ***** github auth & heroku auth *****

GITHUB_USER_DECODE=$(echo -n ${GITHUB_USER} | base64 -d)
GITHUB_PASSWORD_DECODE=$(echo -n ${GITHUB_PASSWORD} | base64 -d)

HEROKU_LOGIN_USER_DECODE=$(echo -n ${HEROKU_LOGIN_USER} | base64 -d)
HEROKU_API_KEY_DECODE=$(echo -n ${HEROKU_API_KEY_ENCODE} | base64 -d)

cat << __HEREDOC__ >> /app/.netrc
machine github.com
  login ${GITHUB_USER_DECODE}
  password ${GITHUB_PASSWORD_DECODE}
machine api.heroku.com
  login ${HEROKU_LOGIN_USER_DECODE}
  password ${HEROKU_API_KEY_DECODE}
machine git.heroku.com
  login ${HEROKU_LOGIN_USER_DECODE}
  password ${HEROKU_API_KEY_DECODE}
__HEREDOC__

cat /app/.netrc

# ***** ccache *****

mkdir -p /tmp/usr/bin

if [ -f bin/ccache ]; then
  cp bin/ccache /tmp/usr/bin/
else
  cp .apt/usr/bin/ccache /tmp/usr/bin/
fi

chmod 777 /tmp/usr/bin/ccache
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

wait

# ***** ssh *****

ssh-keygen -t rsa -N '' -f etc/ssh_host_rsa_key

pushd heroku/bin/

time timeout -sKILL 30 ./heroku ps -a ${DISTCC_HOST_NAME}

./heroku ps:socks -a ${DISTCC_HOST_NAME} &

sleep 15s
SOCKS_PID=$!
ss -antp
ps aux

time timeout -sKILL 30 ./heroku ps:copy /app/ssh_info_user -a ${DISTCC_HOST_NAME}
time timeout -sKILL 30 ./heroku ps:copy /app/ssh_info_http_port -a ${DISTCC_HOST_NAME}
time timeout -sKILL 30 ./heroku ps:copy /app/ssh_info_ssh_port -a ${DISTCC_HOST_NAME}
export TARGET_USER=$(cat ssh_info_user)
export TARGET_HTTP_PORT=$(cat ssh_info_http_port)
export TARGET_SSH_PORT=$(cat ssh_info_ssh_port)

time timeout -sKILL 30 ./heroku ps:copy /app/.ssh/authorized_keys2 -a ${DISTCC_HOST_NAME}
time timeout -sKILL 30 ./heroku ps:copy /app/.ssh/ssh_host_rsa_key2 -a ${DISTCC_HOST_NAME}

mkdir -p -m 700 /app/.ssh
ls -lang /app/.ssh

cp ../../etc/config.ssh /app/.ssh/config

cp authorized_keys2 /app/.ssh/authorized_keys
cp ssh_host_rsa_key2 /app/.ssh/ssh_host_rsa_key

timeout -sKILL 30 ssh -v -p ${TARGET_SSH_PORT} ${TARGET_USER}@0.0.0.0 "ls -lang"

popd

# ***** target *****

pushd build_scripts
chmod +x ./${BUILD_SCRIPT_NAME}.sh
./${BUILD_SCRIPT_NAME}.sh
popd

kill -9 ${SOCKS_PID}

ps aux

pgrep -f "ps:socks -a ${DISTCC_HOST_NAME}"
pgrep -f "ps:socks -a ${DISTCC_HOST_NAME}" | xargs -t -L 1 -n 1 kill -9

ps aux

date
