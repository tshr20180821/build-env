#!/bin/bash

set -x

date

# SSH_VERSION=7_8_P1
# SSH_VERSION=8_1_P1
# SSH_VERSION=8_3_P1
# SSH_VERSION=8_4_P1
SSH_VERSION=8_5_P1

export CFLAGS="-O2 -march=native -mtune=native -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

pushd /tmp

curl -L -O https://github.com/openssh/openssh-portable/archive/V_${SSH_VERSION}.tar.gz
tar xf V_${SSH_VERSION}.tar.gz
pushd openssh-portable-V_${SSH_VERSION}

# curl -O https://ayera.dl.sourceforge.net/project/hpnssh/OpenSSL-1.1%20Compatibility/hpn-openssl1.1-7_8_P1.diff
# curl -O https://excellmedia.dl.sourceforge.net/project/hpnssh/Patches/HPN-SSH%2014v20%208.1p1/openssh-8_1_P1-hpn-14.20.diff
# curl -O https://master.dl.sourceforge.net/project/hpnssh/Patches/HPN-SSH%2014v22%208.3p1/openssh-8_3_P1-hpn-14.22.diff
# curl -O https://master.dl.sourceforge.net/project/hpnssh/Patches/HPN-SSH%2014v22%208.3p1/openssh-8_3_P1-hpn-14.22.diff
# curl -O https://master.dl.sourceforge.net/project/hpnssh/Patches/HPN-SSH%2015v1%208.4p1/openssh-8_4_P1-hpn-15.1.diff
curl -L -o openssh_hpn_patch.diff https://master.dl.sourceforge.net/project/hpnssh/Patches/HPN-SSH%2015v2%208.5p1/openssh-8_5_P1-hpn-15.2.diff

sha512sum openssh_hpn_patch.diff
cat openssh_hpn_patch.diff

ls -lang

# patch -p1 <./hpn-openssl1.1-7_8_P1.diff
# patch -p1 <./openssh-8_1_P1-hpn-14.20.diff
# patch -p1 <./openssh-8_3_P1-hpn-14.22.diff
# patch -p1 <./openssh-8_4_P1-hpn-15.1.diff
patch -p1 <./openssh_hpn_patch.diff

autoreconf
./configure --help
./configure --prefix=/tmp/usr --with-pam --with-ipaddr-display
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
