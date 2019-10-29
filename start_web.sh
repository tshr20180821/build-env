#!/bin/bash

set -x

ldd ./www/curl
./www/curl --version

vendor/bin/heroku-php-apache2 -C apache.conf www
