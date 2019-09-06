# This uses ubuntu version of docker image built in https://github.com/CONABIO/antares3-docker/blob/master/antares3-datacube/conabio_deployment/Dockerfile
sudo add-apt-repository ppa:jonathonf/python-3.6
sudo apt-get update
sudo apt-get install -y python3.6
sudo apt-get install -y python3.6-dev


echo "alias python=python3.6" >> /home/madmex_user/.bash_aliases
echo "export LC_ALL=C.UTF-8" >> /home/madmex_user/.profile
echo "export LANG=C.UTF-8" >> /home/madmex_user/.profile

python3.6 -m pip install --upgrade pip==19.2.2
/home/madmex_user/.local/bin/pip3.6 install --user six==1.11.0
/home/madmex_user/.local/bin/pip3.6 install --user numpy pandas xarray
/home/madmex_user/.local/bin/pip3.6 install --upgrade --user python-dateutil
/home/madmex_user/.local/bin/pip3.6 install --user GDAL==$(gdal-config --version) --global-option=build_ext --global-option='-I/usr/include/gdal'
/home/madmex_user/.local/bin/pip3.6 install --user rasterio --no-binary rasterio
/home/madmex_user/.local/bin/pip3.6 install --user scipy sklearn cloudpickle xgboost lightgbm fiona django --no-binary fiona
/home/madmex_user/.local/bin/pip3.6 install --user --no-cache --no-binary :all: psycopg2
/home/madmex_user/.local/bin/pip3.6 install --user datacube==v1.7.0
/home/madmex_user/.local/bin/pip3.6 install --user git+https://github.com/CONABIO/antares3.git@develop --upgrade

sudo apt-get install -y postgresql-9.5 postgresql-9.5-postgis-2.4
sudo /etc/init.d/postgresql start
sudo -u postgres bash -c 'echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.5/main/pg_hba.conf'
sudo -u postgres bash -c 'echo "local all all md5" >> /etc/postgresql/9.5/main/pg_hba.conf'
sudo -u postgres bash -c "echo listen_addresses=\'*\' >> /etc/postgresql/9.5/main/postgresql.conf"
sudo -u postgres psql --command "ALTER USER postgres WITH PASSWORD 'postgres';"
sudo -u postgres bash -c 'psql --command "CREATE EXTENSION postgis;"'
sudo /etc/init.d/postgresql restart
