#!/bin/bash

set -x

/usr/sbin/sshd --version
/usr/sbin/sshd --help

timeout -sKILL 10 ss -t

vendor/bin/heroku-php-apache2 -C apache.conf www
