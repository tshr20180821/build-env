#!/bin/bash

set -x

vendor/bin/heroku-php-apache2 -C apache.conf www
