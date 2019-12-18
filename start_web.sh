#!/bin/bash

set -x

# ***** env ******

echo 'Processor Count : ' $(grep -c -e processor /proc/cpuinfo)
cat /proc/cpuinfo | head -n $(($(cat /proc/cpuinfo | wc -l) / $(grep -c -e processor /proc/cpuinfo)))

cat /proc/version

hostname -i
whoami

whereis gcc
gcc --version

ldd ./www/svn
./www/svn --version

echo 'ulimit -u : ' $(ulimit -u)
echo 'getconf ARG_MAX : ' $(printf "%'d\n" $(getconf ARG_MAX))

# ***** distccd *****

mkdir /tmp/bin

if [ -f /app/bin/distccd ]; then
  chmod +x /app/bin/distccd
  ln -s /app/bin/distccd /tmp/bin/distccd
else
  ln -s /app/.apt/usr/bin/distccd /tmp/bin/distccd
fi
/tmp/bin/distccd --version
ldd /tmp/bin/distccd

export DISTCC_LOG=/tmp/distcc.log
touch ${DISTCC_LOG}
chmod 666 ${DISTCC_LOG}
tail -qF -n 0 ${DISTCC_LOG} &

# ***** sshd *****

mkdir -m 700 .ssh
ls -lang .ssh
# mv etc/config.ssh .ssh/config
mv etc/ssh_host_rsa_key.pub .ssh/authorized_keys2
mv etc/ssh_host_rsa_key .ssh/ssh_host_rsa_key2

# chmod 600 .ssh/config
chmod 600 .ssh/authorized_keys2
chmod 600 .ssh/ssh_host_rsa_key2

gcc -### -E - -march=native 2>&1 | sed -r '/cc1/!d;s/(")|(^.* - )//g' >cflags_option

ssh -V

cat /app/.ssh/sshd_config

test ${PORT} -ne 60022 && export PORT_SSHD=60022 || export PORT_SSHD=61022

if [ -f /app/bin/hpn-sshd ]; then
  ln -s /app/bin/hpn-sshd /app/bin/ssh2d
  echo NoneEnabled=yes >>./etc/sshd_config
  cat ./etc/sshd_config
  echo -n yes >is_hpn_sshd
else
  ln -s /usr/sbin/sshd /app/bin/ssh2d
  echo -n no >is_hpn_sshd
fi

echo -n $(whoami) >ssh_info_user
echo -n ${PORT} >ssh_info_http_port
echo -n ${PORT_SSHD} >ssh_info_ssh_port

mkdir /tmp/archive
cp .ssh/authorized_keys2 /tmp/archive/
cp .ssh/ssh_host_rsa_key2 /tmp/archive/
mv cflags_option /tmp/archive/
mv ssh_info_user /tmp/archive/
mv ssh_info_http_port /tmp/archive/
mv ssh_info_ssh_port /tmp/archive/
mv is_hpn_sshd /tmp/archive/
pushd /tmp/archive
tar cJvf files.tar.xz *
popd

ls -lang /app/bin

touch /tmp/ssh2d_log
tail -qF -n 0 /tmp/ssh2d_log &

/app/bin/ssh2d -D -E /tmp/ssh2d_log -p ${PORT_SSHD} -f ./etc/sshd_config &

# ***** etc *****

echo 'env size : ' $(printf "%'d" $(printenv | wc -c)) 'byte'

printenv | sort

./heroku/bin/heroku status &

# sleep 10 && ps aux &

# sleep 15 && kill -HUP $(ss -ltnp | grep 1092 | head -n 1 | grep -o -E 'pid=[0-9]+' | grep -o -E '[0-9]+') &

sleep 20 && ss -atnp &

sleep 25 && ps aux &

vendor/bin/heroku-php-apache2 -C apache.conf www
