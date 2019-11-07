#!/bin/bash

set -x

hostname -i
echo ${PORT}
whoami

ls -lang /app/.apt/usr/bin

whereis distcc
distcc --version

# sleep 10 && timeout -sKILL 10 ss -ant &

vendor/bin/heroku-php-apache2 -C apache.conf www
