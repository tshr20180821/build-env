#!/bin/bash

set -x

date

pushd /tmp

time git clone --depth=1 -b OpenSSL_1_0_2u https://github.com/openssl/openssl.git

pushd openssl
# time ./config -fPIC shared
./config --prefix=/tmp/usr shared

time timeout -sKILL 180 make -j2
make install

popd
popd

tree /tmp/usr

strings /tmp/usr/lib/libcrypto.so.1.0.0
strings /tmp/usr/lib/libssl.so.1.0.0
