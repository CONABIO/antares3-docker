#!/bin/bash
nombre_base_de_datos=antares_datacube
sudo apt-get update
sudo service ssh restart
sudo apt-get install -y \
            postgresql \
            postgresql-client \
            postgresql-10-postgis-2.4

sudo /etc/init.d/postgresql start
sudo echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/10/main/pg_hba.conf
sudo echo "local all all md5" >> /etc/postgresql/10/main/pg_hba.conf
sudo echo "listen_addresses='*'" >> /etc/postgresql/10/main/postgresql.conf
psql --command "ALTER USER postgres WITH PASSWORD 'postgres';"
psql --command "CREATE EXTENSION postgis;"
sudo /etc/init.d/postgresql restart
echo "export LC_ALL=C.UTF-8" >> ~/.profile
echo "export LANG=C.UTF-8" >> ~/.profile
cp /etc/skel/.bashrc /home/postgres/.
cp /etc/skel/.profile /home/postgres/.
createdb $nombre_base_de_datos
