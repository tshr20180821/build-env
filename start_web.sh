#!/bin/bash

set -x

# ***** env ******

echo 'Processor Count : ' $(grep -c -e processor /proc/cpuinfo)
cat /proc/cpuinfo | head -n $(($(cat /proc/cpuinfo | wc -l) / $(grep -c -e processor /proc/cpuinfo)))

cat /proc/version

whereis gcc
gcc --version

echo 'ulimit -u : ' $(ulimit -u)
echo 'getconf ARG_MAX : ' $(printf "%'d\n" $(getconf ARG_MAX))

# ***** sshd *****

mkdir -m 700 .ssh
mv etc/config.ssh .ssh/config
mv etc/ssh_host_rsa_key.pub .ssh/authorized_keys2
mv etc/ssh_host_rsa_key .ssh/ssh_host_rsa_key2

chmod 600 .ssh/config
chmod 600 .ssh/authorized_keys2
chmod 600 .ssh/ssh_host_rsa_key2

touch /tmp/ssh2d_log
chmod 666 /tmp/ssh2d_log

ssh -V

cat /app/.ssh/sshd_config

test ${PORT} -ne 60022 && export PORT_SSHD=60022 || export PORT_SSHD=61022

echo -n $(whoami) >ssh_info_user
echo -n ${PORT} >ssh_info_http_port
echo -n ${PORT_SSHD} >ssh_info_ssh_port

ln -s /usr/sbin/sshd /app/bin/ssh2d

ls -lang /app/bin

/app/bin/ssh2d -D -E /tmp/ssh2d_log -p ${PORT_SSHD} -f etc/sshd_config &

tail -f /tmp/ssh2d_log &

# ***** etc *****

hostname -i
echo ${PORT}
whoami

ls -lang /app/.apt/usr/bin

whereis distcc
distcc --version

sleep 15 && ss -atnp &

vendor/bin/heroku-php-apache2 -C apache.conf www
