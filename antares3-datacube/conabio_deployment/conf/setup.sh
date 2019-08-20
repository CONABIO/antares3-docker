#!/bin/bash
sudo chmod -R gou+wrx /shared_volume
sudo chmod -R gou+rwx /home/madmex_user/

sudo apt-get update
sudo apt-get install -y nodejs
sudo service ssh restart
cp /etc/skel/.bashrc /home/madmex_user/.
cp /etc/skel/.profile /home/madmex_user/.
echo "export LC_ALL=C.UTF-8" >> ~/.profile
echo "export LANG=C.UTF-8" >> ~/.profile
mkdir -p /home/madmex_user/.virtualenvs
echo 'export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3 && source /usr/local/bin/virtualenvwrapper.sh' >> /home/madmex_user/.bash_aliases
echo "alias python=python3" >> /home/madmex_user/.bash_aliases
export PATH="/home/madmex_user/.local/bin:$PATH"
echo 'export PATH=/home/madmex_user/.local/bin:$PATH' >> ~/.profile
pip3 install --upgrade --user python-dateutil 
pip3 install --user numpy
pip3 install --user GDAL==$(gdal-config --version) --global-option=build_ext --global-option='-I/usr/include/gdal'
pip3 install --user rasterio --no-binary rasterio
pip3 install --user scipy sklearn cloudpickle xgboost lightgbm fiona django --no-binary fiona
pip3 install --user --no-cache --no-binary :all: psycopg2
pip3 install --user dask distributed bokeh --upgrade
pip3 install --user git+https://github.com/opendatacube/datacube-core.git@develop#egg=datacube[s3]
pip3 install --user boto3 botocore awscli --upgrade
pip3 install --user jupyter jupyterlab --upgrade
pip3 install --user git+https://github.com/CONABIO/antares3.git@training-data-model-fit --upgrade
 

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

echo 'export GDAL_DATA=/usr/share/gdal/' >> /home/madmex_user/.profile

ln -sf /shared_volume/.antares ~/.antares
ln -sf /shared_volume/.datacube.conf ~/.datacube.conf
