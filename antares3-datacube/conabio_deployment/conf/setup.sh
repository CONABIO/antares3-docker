#!/bin/bash
sudo chmod -R gou+wrx /shared_volume
sudo chmod -R gou+rwx /home/madmex_user/

sudo add-apt-repository ppa:jonathonf/python-3.6
sudo apt-get update
sudo apt-get install -y python3.6
sudo apt-get install -y python3.6-dev


sudo apt-get update
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo service ssh restart
cp /etc/skel/.bashrc /home/madmex_user/.
cp /etc/skel/.profile /home/madmex_user/.
echo "export LC_ALL=C.UTF-8" >> ~/.profile
echo "export LANG=C.UTF-8" >> ~/.profile
mkdir -p /home/madmex_user/.virtualenvs
echo 'export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3 && source /usr/local/bin/virtualenvwrapper.sh' >> /home/madmex_user/.bash_aliases

echo "alias python=python3.6" >> /home/madmex_user/.bash_aliases
export PATH="/home/madmex_user/.local/bin:$PATH"
echo 'export PATH=/home/madmex_user/.local/bin:$PATH' >> ~/.profile

python3.6 -m pip install --upgrade pip==19.2.2
python3.6 -m pip install --user six==1.11.0
python3.6 -m pip install --user numpy pandas xarray
python3.6 -m pip install --user jupyter jupyterlab
python3.6 -m pip install --user dask distributed
python3.6 -m pip install --upgrade --user python-dateutil
python3.6 -m pip install --user GDAL==$(gdal-config --version) --global-option=build_ext --global-option='-I/usr/include/gdal'

python3.6 -m pip install --user rasterio --no-binary rasterio
python3.6 -m pip install --user scipy sklearn cloudpickle xgboost lightgbm fiona django --no-binary fiona
python3.6 -m pip install --user --no-cache --no-binary :all: psycopg2

python3.6 -m pip install --user datacube[s3]==v1.7.0
python3.6 -m pip install --user boto3 botocore awscli --upgrade

python3.6 -m pip install --user git+https://github.com/CONABIO/antares3.git@training-data-model-fit --upgrade


#create .jupyter directory
jupyter notebook --generate-config

#copy to shared_volume

mkdir /shared_volume/.jupyter
sudo cp -r /home/madmex_user/.jupyter/jupyter_notebook_config.py /shared_volume/.jupyter/
sudo chown -Rh madmex_user:madmex_user /shared_volume/.jupyter/jupyter_notebook_config.py


#create symbolic link to /shared_volume/.jupyter:
ln -sf /shared_volume/.jupyter/jupyter_notebook_config.py /home/madmex_user/.jupyter/jupyter_notebook_config.py

#edit

sed -i "s/#c.NotebookApp.password = .*/c.NotebookApp.password = u'sha1:e47d7d0c0c23:22db3ffa5484ff0c18234217279b117a525a337a'/" /shared_volume/.jupyter/jupyter_notebook_config.py

sed -i 's/#c.NotebookApp.port = .*/c.NotebookApp.port = 10000/' /shared_volume/.jupyter/jupyter_notebook_config.py

echo 'export GDAL_DATA=/usr/share/gdal/2.2' >> /home/madmex_user/.profile

ln -sf /shared_volume/.antares ~/.antares
ln -sf /shared_volume/.datacube.conf ~/.datacube.conf


#install R
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
