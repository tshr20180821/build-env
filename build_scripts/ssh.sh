#!/bin/bash

set -x

date

SSH_VERSION=8_1_P1
# SSH_VERSION=7_8_P1

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

curl -L -O https://github.com/openssh/openssh-portable/archive/V_${SSH_VERSION}.tar.gz
tar xf V_${SSH_VERSION}.tar.gz
pushd openssh-portable-V_${SSH_VERSION}

curl -O https://excellmedia.dl.sourceforge.net/project/hpnssh/Patches/HPN-SSH%2014v20%208.1p1/openssh-8_1_P1-hpn-14.20.diff
# curl -O https://ayera.dl.sourceforge.net/project/hpnssh/OpenSSL-1.1%20Compatibility/hpn-openssl1.1-7_8_P1.diff

ls -lang

patch -p1 <./openssh-8_1_P1-hpn-14.20.diff
# patch -p1 <./hpn-openssl1.1-7_8_P1.diff

autoreconf
./configure --help
./configure --prefix=/tmp/usr --with-pam
time timeout -sKILL 210 make -j$(grep -c -e processor /proc/cpuinfo)
ls -lang
popd
popd

ldd /tmp/openssh-portable-V_${SSH_VERSION}/ssh
ldd /tmp/openssh-portable-V_${SSH_VERSION}/sshd

/tmp/openssh-portable-V_${SSH_VERSION}/ssh -V

cp /tmp/openssh-portable-V_${SSH_VERSION}/ssh ../www/
cp /tmp/openssh-portable-V_${SSH_VERSION}/sshd ../www/

date
