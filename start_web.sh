#!/bin/bash

set -x

# ***** env ******

export HEROKU_EXEC_DEBUG=1

echo 'Processor Count : ' $(grep -c -e processor /proc/cpuinfo)
cat /proc/cpuinfo | head -n $(($(cat /proc/cpuinfo | wc -l) / $(grep -c -e processor /proc/cpuinfo)))

cat /proc/version

hostname -i
whoami

whereis gcc
gcc --version
whereis distcc
distcc --version

echo 'ulimit -u : ' $(ulimit -u)
echo 'getconf ARG_MAX : ' $(printf "%'d\n" $(getconf ARG_MAX))

# ***** sshd *****

mkdir -m 700 .ssh
ls -lang .ssh
mv etc/config.ssh .ssh/config
mv etc/ssh_host_rsa_key.pub .ssh/authorized_keys2
mv etc/ssh_host_rsa_key .ssh/ssh_host_rsa_key2

chmod 600 .ssh/config
chmod 600 .ssh/authorized_keys2
chmod 600 .ssh/ssh_host_rsa_key2

gcc -### -E - -march=native 2>&1 | sed -r '/cc1/!d;s/(")|(^.* - )//g' >cflags_option

touch /tmp/ssh2d_log
chmod 666 /tmp/ssh2d_log

ssh -V

cat /app/.ssh/sshd_config

test ${PORT} -ne 60022 && export PORT_SSHD=60022 || export PORT_SSHD=61022

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
pushd /tmp/archive
tar cJvf files.tar.xz *
popd

ln -s /usr/sbin/sshd /app/bin/ssh2d

ls -lang /app/bin

/app/bin/ssh2d -D -E /tmp/ssh2d_log -p ${PORT_SSHD} -f etc/sshd_config &

tail -f /tmp/ssh2d_log &

# ***** etc *****

ls -lang /app/.apt/usr/bin

export DISTCC_LOG=/tmp/distcc.log
touch ${DISTCC_LOG}
chmod 666 ${DISTCC_LOG}
tail -f ${DISTCC_LOG} &

echo 'env size : ' $(printf "%'d" $(printenv | wc -c)) 'byte'

printenv | sort

kill -HUP $(ss -ltnp | grep 1092 | head -n 1 | grep -o -E 'pid=[0-9]+' | grep -o -E '[0-9]+') &

./heroku/bin/heroku status &

# sleep 10 && ps aux &

# sleep 15 && kill -HUP $(ss -ltnp | grep 1092 | head -n 1 | grep -o -E 'pid=[0-9]+' | grep -o -E '[0-9]+') &

sleep 20 && ss -atnp &

sleep 25 && ps aux &

vendor/bin/heroku-php-apache2 -C apache.conf www
