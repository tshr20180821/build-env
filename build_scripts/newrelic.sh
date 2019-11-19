#!/bin/bash

set -x

date

NEWRELIC_VERSION=9.3.0.248

curl -L -o /tmp/newrelic-php5-common_${NEWRELIC_VERSION}_all.deb \
  https://download.newrelic.com/debian/dists/newrelic/non-free/binary-amd64/newrelic-php5-common_${NEWRELIC_VERSION}_all.deb

dpkg --help
time dpkg -i newrelic-php5-common_${NEWRELIC_VERSION}_all.deb

date
