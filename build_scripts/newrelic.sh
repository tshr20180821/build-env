#!/bin/bash

set -x

date

NEWRELIC_VERSION=9.3.0.248

time curl -sSL -o /tmp/newrelic-php5-common_${NEWRELIC_VERSION}_all.deb \
  https://download.newrelic.com/debian/dists/newrelic/non-free/binary-amd64/newrelic-php5-common_${NEWRELIC_VERSION}_all.deb
time curl -sSL -o /tmp/newrelic-daemon_${NEWRELIC_VERSION}_amd64.deb \
  https://download.newrelic.com/debian/dists/newrelic/non-free/binary-amd64/newrelic-daemon_${NEWRELIC_VERSION}_amd64.deb
time curl -sSL -o /tmp/newrelic-php5_${NEWRELIC_VERSION}_amd64.deb \
  https://download.newrelic.com/debian/dists/newrelic/non-free/binary-amd64/newrelic-php5_${NEWRELIC_VERSION}_amd64.deb

dpkg-deb --help
dpkg-deb -x /tmp/newrelic-php5-common_${NEWRELIC_VERSION}_all.deb .apt
dpkg-deb -x /tmp/newrelic-daemon_${NEWRELIC_VERSION}_amd64.deb .apt
dpkg-deb -x /tmp/newrelic-php5_${NEWRELIC_VERSION}_amd64.deb .apt
tree .apt

date
