#!/bin/bash

#not sure if next two lines are necessary ...
sudo chmod -R gou+wrx /shared_volume
sudo chmod -R gou+rwx /home/madmex_user/

sudo add-apt-repository ppa:jonathonf/python-3.6
sudo apt-get update
sudo apt-get install -y python3.6
sudo apt-get install -y python3.6-dev

#install nodejs for jupyterlab
sudo apt-get update
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs

#some configs
sudo service ssh restart
antares_branch=rapideye-support
cp /etc/skel/.bashrc /home/madmex_user/.
cp /etc/skel/.profile /home/madmex_user/.
echo "export LC_ALL=C.UTF-8" >> ~/.profile
echo "export LANG=C.UTF-8" >> ~/.profile
mkdir -p /home/madmex_user/.virtualenvs
echo 'export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3 && source /usr/local/bin/virtualenvwrapper.sh' >> /home/madmex_user/.bash_aliases

echo "alias python=python3.6" >> /home/madmex_user/.bash_aliases
export PATH="/home/madmex_user/.local/bin:$PATH"
echo 'export PATH=/home/madmex_user/.local/bin:$PATH' >> ~/.profile

#use python3.6 and pip3.6 to install packages in ubuntu xenial 16.04
python3.6 -m pip install --upgrade pip==19.2.2
pip3.6 install --user six==1.11.0
pip3.6 install --user numpy pandas xarray 
pip3.6 install --user jupyter jupyterlab
pip3.6 install --user dask distributed bokeh
pip3.6 install --install --user python-dateutil==2.8.0
pip3.6 install --user GDAL==$(gdal-config --version) --global-option=build_ext --global-option='-I/usr/include/gdal'

pip3.6 install --user rasterio --no-binary rasterio
pip3.6 install --user scipy sklearn cloudpickle xgboost lightgbm fiona django==2.2.8 geopandas rtree --no-binary fiona
pip3.6 install --user --no-cache --no-binary :all: psycopg2
pip3.6 install --user datacube[s3]==v1.7.0
pip3.6 install --user boto3 botocore awscli --upgrade
pip3.6 install --user git+https://github.com/CONABIO/antares3.git@$antares_branch --upgrade --no-deps
pip3.6 install --user sentinelsat
pip3.6 install --user ephem


#create .jupyter directory
jupyter notebook --generate-config

#copy to shared_volume

mkdir /shared_volume/.jupyter
sudo cp -r /home/madmex_user/.jupyter/jupyter_notebook_config.py /shared_volume/.jupyter/
sudo chown -Rh madmex_user:madmex_user /shared_volume/.jupyter/jupyter_notebook_config.py


#create symbolic link to /shared_volume/.jupyter:
ln -sf /shared_volume/.jupyter/jupyter_notebook_config.py /home/madmex_user/.jupyter/jupyter_notebook_config.py

#edit conf of jupyter

sed -i "s/#c.NotebookApp.password = .*/c.NotebookApp.password = u'sha1:e47d7d0c0c23:22db3ffa5484ff0c18234217279b117a525a337a'/" /shared_volume/.jupyter/jupyter_notebook_config.py

sed -i 's/#c.NotebookApp.port = .*/c.NotebookApp.port = 10000/' /shared_volume/.jupyter/jupyter_notebook_config.py

echo 'export GDAL_DATA=/usr/share/gdal/2.2' >> /home/madmex_user/.profile
echo 'export HDF5_USE_FILE_LOCKING=FALSE' >> /home/madmex_user/.profile

#some configs for antares & datacube
ln -sf /shared_volume/.antares ~/.antares
ln -sf /shared_volume/.datacube.conf ~/.datacube.conf


#install R & extension for jupyterlab integration
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo apt-get install apt-transport-https
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran35/'
sudo apt update
sudo apt install -y r-base

sudo chmod gou+wrx -R /usr/local/lib/R/site-library/

sudo apt-get install -y libssl-dev libxml2-dev libcurl4-openssl-dev

sudo R -e 'install.packages(c("repr", "IRdisplay", "evaluate", "crayon", "pbdZMQ", "devtools", "uuid", "digest"), lib="/usr/local/lib/R/site-library/")'

R -e 'devtools::install_github("IRkernel/IRkernel")'

R -e 'IRkernel::installspec()'
