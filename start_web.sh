#!/bin/bash

set -x

ldd ./www/aria2c
./www/aria2c --version

vendor/bin/heroku-php-apache2 -C apache.conf www
