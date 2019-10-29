#!/bin/bash

set -x

ldd ./www/ccache
./www/ccache --version

vendor/bin/heroku-php-apache2 -C apache.conf www
