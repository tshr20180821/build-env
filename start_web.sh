#!/bin/bash

set -x

ldd ./bin/git
./bin/git --version

vendor/bin/heroku-php-apache2 -C apache.conf www
