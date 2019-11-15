#!/bin/bash

set -x

date

cflags_option=$(cat /tmp/cflags_option)
export CFLAGS="-O2 ${cflags_option} -pipe -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-fuse-ld=gold"

mkdir -m 777 /tmp/usr/bin

ls /usr/bin | xargs -n 1 -I {} ln -s /usr/bin/{} /tmp/usr/bin/{}
rm /tmp/usr/bin/make

cat << '__HEREDOC__' >/tmp/usr/bin/make
#!/bin/bash

set -x

echo $@
/usr/bin/make -j2 $@
__HEREDOC__

chmod +x /tmp/usr/bin/make

export PATH="/tmp/usr/bin:${PATH}"
export PATH_OLD=${PATH}
export PATH=$(echo ${PATH} | sed -e 's|:/usr/bin:||g')

whereis make
echo ${PATH}

export PYTHONUSERBASE=/tmp/python
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
time python /tmp/get-pip.py --user

/tmp/python/bin/pip --help
/tmp/python/bin/pip install --help

# time /tmp/python/bin/pip install -I --user bzr mercurial
time /tmp/python/bin/pip install --no-color -I --user bzr

rm /tmp/usr/bin/make
export PATH=${PATH_OLD}

date
