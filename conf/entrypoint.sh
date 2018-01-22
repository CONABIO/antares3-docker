#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-9001}

echo "Starting with UID : $USER_ID"
useradd --shell /bin/bash -u $USER_ID -o -c "" --create-home madmex_user && echo 'madmex_user:qwerty' | chpasswd
su - madmex_user
export HOME=/home/madmex_user
cp /etc/skel/.bashrc /home/madmex_user/.
mkdir -p /home/madmex_user/.virtualenvs
mkdir -p /home/madmex_user/git && mkdir -p /home/madmex_user/sandbox
echo 'source /usr/local/bin/virtualenvwrapper.sh' >> /home/madmex_user/.bash_aliasesexec /usr/local/bin/gosu madmex_user "$@"
echo "alias python=python3" >> /home/madmex_user/.bash_aliases
cd /home/madmex_user/git && git clone https://github.com/CONABIO/antares3.git && cd antares3 && git checkout -b develop origin/develop
/bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh && alias python=python3 && mkvirtualenv antares && pip install numpy && pip install cloudpickle && pip install GDAL==$(gdal-config --version) --global-option=build_ext --global-option='-I/usr/include/gdal' && pip install git+https://github.com/CONABIO/datacube-core.git@release-1.5"
# HAndle conf files
mkdir -p /home/madmex_user/conf
cp ~/conf/.datacube.conf /home/madmex_user/.datacube.conf
cp ~/conf/.env /home/madmex_user/antares3/madmex/.env

