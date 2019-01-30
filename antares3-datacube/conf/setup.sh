#!/bin/bash
sudo service ssh restart
cp /etc/skel/.bashrc /home/madmex_user/.
cp /etc/skel/.profile /home/madmex_user/.
mkdir -p /home/madmex_user/.virtualenvs
mkdir -p /home/madmex_user/git && mkdir -p /home/madmex_user/sandbox
echo 'source /usr/local/bin/virtualenvwrapper.sh' >> /home/madmex_user/.bash_aliases
echo "alias python=python3" >> /home/madmex_user/.bash_aliases
echo "export LC_ALL=C.UTF-8" >> ~/.profile
echo "export LANG=C.UTF-8" >> ~/.profile
cd /home/madmex_user/git && git clone https://github.com/CONABIO/antares3.git && cd antares3 && git checkout -b develop origin/develop
pip3 install --upgrade pip==9.0.3
/bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh && alias python=python3 && mkvirtualenv antares && pip3 install dask distributed --upgrade && pip3 install bokeh && pip3 install --upgrade python-dateutil && pip install numpy==1.14.4 && pip install cloudpickle && pip install GDAL==$(gdal-config --version) --global-option=build_ext --global-option='-I/usr/include/gdal' && pip install rasterio==1.0.2 --no-binary rasterio && pip install scipy sklearn lightgbm fiona django --no-binary fiona && pip install --no-cache --no-binary :all: psycopg2 && pip install git+https://github.com/opendatacube/datacube-core.git@develop#egg=datacube[s3] && pip install boto3 botocore awscli --upgrade && pip install jupyter jupyterlab --upgrade && cd /home/madmex_user/git/antares3 && pip install -e ."
# HAndle conf files
#mkdir -p /home/madmex_user/conf
#cp ~/conf/.datacube.conf /home/madmex_user/.datacube.conf
#cp ~/credentials/.env /home/madmex_user/git/antares3/madmex/.env
 
