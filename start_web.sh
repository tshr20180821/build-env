#!/bin/bash

set -x

ldd ./www/aria2c
./www/aria2c --version

timeout -sKILL 10 ss -t

vendor/bin/heroku-php-apache2 -C apache.conf www
