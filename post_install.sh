#!/bin/bash

set -x

date
timestamp=$(date +%s)

chmod +x ./start_web.sh

curl -s https://${DISTCC_HOST_NAME}.herokuapp.com/ >/dev/null 2>&1 &

ss -ant

# ***** env *****

echo 'Processor Count : ' $(grep -c -e processor /proc/cpuinfo)
cat /proc/cpuinfo | head -n $(($(cat /proc/cpuinfo | wc -l) / $(grep -c -e processor /proc/cpuinfo)))

cat /proc/version

whereis gcc
gcc --version
ldd /usr/bin/gcc

chmod +x ./build_scripts/${BUILD_SCRIPT_NAME}.sh

# ***** target *****

if [ ${NEED_DISTCC} != "yes" ]; then
  pushd build_scripts
  ./${BUILD_SCRIPT_NAME}.sh
  popd
  ssh-keygen -t rsa -N '' -f etc/ssh_host_rsa_key
  date
  exit
fi

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

# ***** heroku cli *****

curl -sS --create-dirs -o heroku/heroku.tar.xz $(curl -sS https://cli-assets.heroku.com/linux-x64 | grep -o -E https.+xz)

pushd heroku
tar xf heroku.tar.xz --strip-components=1
rm heroku.tar.xz
# time ./bin/heroku update &
time ./bin/heroku plugins:install heroku-builds &
popd

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
git clone --depth=1 https://github.com/tshr20180821/build-env.git
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

whereis ssh

mkdir /tmp/bin
if [ -f ./bin/hpn-ssh ]; then
  cp ./bin/hpn-ssh /tmp/bin
  chmod +x /tmp/bin/hpn-ssh
  ln -s /tmp/bin/hpn-ssh /tmp/bin/ssh2
  export IS_HPN_SSH=yes
else
  ln -s /usr/bin/ssh /tmp/bin/ssh2
  export IS_HPN_SSH=no
fi
ls -lang /tmp/bin
/tmp/bin/ssh2 -V
/tmp/bin/ssh2 --help

pushd heroku/bin/

./heroku ps -a ${DISTCC_HOST_NAME}

time timeout -sKILL 30 ./heroku ps:copy /tmp/archive/files.tar.xz -a ${DISTCC_HOST_NAME}
tar xf files.tar.xz
if [ ! -f ./ssh_info_user ]; then
  time timeout -sKILL 30 echo y | ./heroku ps:copy /tmp/archive/files.tar.xz -a ${DISTCC_HOST_NAME}
  tar xf files.tar.xz
fi

if [ -f ./ssh_info_user ]; then
  export TARGET_USER=$(cat ssh_info_user)
  export TARGET_HTTP_PORT=$(cat ssh_info_http_port)
  export TARGET_SSH_PORT=$(cat ssh_info_ssh_port)
  export IS_HPN_SSHD=$(cat is_hpn_sshd)
  mv cflags_option /tmp/cflags_option

  mkdir -p -m 700 /app/.ssh
  ls -lang /app/.ssh

  # cp ../../etc/config.ssh /app/.ssh/config
  cp ../../etc/config.ssh /tmp/ssh_config

  cp authorized_keys2 /app/.ssh/authorized_keys
  cp ssh_host_rsa_key2 /app/.ssh/ssh_host_rsa_key

  ./heroku ps:socks -a ${DISTCC_HOST_NAME} &

  for i in {1..30}; do
    sleep 1s
    if [ $(ss -antp | grep -c 127.0.0.1:1080) -eq 1 ]; then
      break;
    fi
  done

  ss -antp
  ps aux
  curl -v --socks5 127.0.0.1:1080 0.0.0.0:${TARGET_HTTP_PORT}

  # timeout -sKILL 30 ssh -v -F /tmp/ssh_config -p ${TARGET_SSH_PORT} ${TARGET_USER}@0.0.0.0 'ls -lang'
  # timeout -sKILL 30 ssh -F /tmp/ssh_config -p ${TARGET_SSH_PORT} ${TARGET_USER}@0.0.0.0 'ls -lang'
  if [ ${IS_HPN_SSHD} = 'yes' ] && [ ${IS_HPN_SSH} = 'yes' ]; then
    export HPN_SSH_OPTION="-oNoneSwitch=yes -oNoneEnabled=yes"
  fi
  timeout -sKILL 30 /tmp/bin/ssh2 -F /tmp/ssh_config ${HPN_SSH_OPTION} -p ${TARGET_SSH_PORT} ${TARGET_USER}@0.0.0.0 'ls -lang'
fi

popd

# ***** distcc *****

whereis distcc

mkdir /tmp/bin

if [ -f ./bin/distcc ]; then
  cp ./bin/distcc /tmp/bin
else
  cp $(pwd)/.apt/usr/bin/distcc /tmp/bin
fi

chmod +x /tmp/bin/distcc
/tmp/bin/distcc --version
/tmp/bin/distcc --help

pushd /tmp/bin
cat << '__HEREDOC__' >distcc-ssh
#!/bin/bash

set -x

# echo "DISTCC_SSH_LOG $(date +%Y/%m/%d" "%H:%M:%S) $*"
# exec ssh -F /tmp/ssh_config -p ${TARGET_SSH_PORT} -l ${TARGET_USER} "$@"
exec /tmp/bin/ssh2 -F /tmp/ssh_config ${HPN_SSH_OPTION} -p ${TARGET_SSH_PORT} -l ${TARGET_USER} "$@"
__HEREDOC__
chmod +x distcc-ssh
cat distcc-ssh
popd

export DISTCC_HOSTS="localhost/1 @0.0.0.0/8:/app/bin/distccd_start"
export DISTCC_POTENTIAL_HOSTS=${DISTCC_HOSTS}
export DISTCC_SSH="/tmp/bin/distcc-ssh"

chmod +x ./bin/distccd_start

# ***** target *****

pushd build_scripts
./${BUILD_SCRIPT_NAME}.sh
popd

# ps aux

pgrep -f "ps:socks -a ${DISTCC_HOST_NAME}" | xargs -t -L 1 -n 1 kill -9
pgrep -f "ssh2: /tmp/ssh_master-${TARGET_USER}@0.0.0.0:${TARGET_SSH_PORT}" | xargs -t -L 1 -n 1 kill -9

# ps aux

rm -rf .apt/usr/share/man .apt/usr/share/doc

date
timestamp=$(($(date +%s)-${timestamp}))
date -d @${timestamp} +"%-M:%S"
