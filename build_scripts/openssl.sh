#!/bin/bash

set -x

date

pushd /tmp

time git clone --depth=1 -b OpenSSL_1_0_2-stable https://github.com/openssl/openssl.git

./config -fPIC shared

time make -j2

popd
