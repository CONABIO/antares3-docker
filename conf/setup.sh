#!/bin/bash
sudo service ssh restart
sudo apt-get install -y  \
postgresql-9.5 \
postgresql-contrib-9.5 \
postgresql-client-9.5
sudo /etc/init.d/postgresql start
echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.5/main/pg_hba.conf
echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf
createdb -O madmex_user madmex_user
psql --command "ALTER USER madmex_user WITH PASSWORD 'qwerty';"
cp /etc/skel/.bashrc /home/madmex_user/.
cp /etc/skel/.profile /home/madmex_user/.
mkdir -p /home/madmex_user/.virtualenvs
mkdir -p /home/madmex_user/git && mkdir -p /home/madmex_user/sandbox
echo 'source /usr/local/bin/virtualenvwrapper.sh' >> /home/madmex_user/.bash_aliases
echo "alias python=python3" >> /home/madmex_user/.bash_aliases
cd /home/madmex_user/git && git clone https://github.com/CONABIO/antares3.git && cd antares3 && git checkout -b develop origin/develop
/bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh && alias python=python3 && mkvirtualenv antares && pip install numpy && pip install cloudpickle && pip install GDAL==$(gdal-config --version) --global-option=build_ext --global-option='-I/usr/include/gdal' && pip install git+https://github.com/CONABIO/datacube-core.git@release-1.5"
# HAndle conf files
mkdir -p /home/madmex_user/conf
cp ~/conf/.datacube.conf /home/madmex_user/.datacube.conf
cp ~/conf/.env /home/madmex_user/git/antares3/madmex/.env
