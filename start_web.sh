#!/bin/bash

set -x

/usr/sbin/sshd -V

/usr/sbin/sshd -4 -f etc/sshd_config &

timeout -sKILL 10 ss -t

vendor/bin/heroku-php-apache2 -C apache.conf www
