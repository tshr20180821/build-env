#!/bin/bash

set -x

date

cflags_option=$(cat /tmp/cflags_option)
export CFLAGS="-O2 ${cflags_option} -pipe -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

mkdir -m 777 /tmp/usr/bin

cat << '__HEREDOC__' >/tmp/usr/bin/make
#!/bin/bash

set -x

echo $@
/usr/bin/make -j2 $@
__HEREDOC__

export PATH="/tmp/usr/bin:${PATH}"

chmod +x /tmp/usr/bin/make
whereis make
echo ${PATH}

export PYTHONUSERBASE=/tmp/python
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
time python /tmp/get-pip.py --user

/tmp/python/bin/pip --help
/tmp/python/bin/pip install --help

# time /tmp/python/bin/pip install -I --user bzr mercurial
time /tmp/python/bin/pip install -v --no-color -I --user bzr

date
