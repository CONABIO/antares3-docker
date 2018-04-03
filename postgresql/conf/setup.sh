#!/bin/bash
sudo service ssh restart
sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y \
postgresql-9.5 \
postgresql-contrib-9.5 \
postgresql-client-9.5 \
postgresql-9.5-postgis-2.3
sudo /etc/init.d/postgresql start
echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.5/main/pg_hba.conf
echo "local all all md5" >> /etc/postgresql/9.5/main/pg_hba.conf
echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf
sudo /etc/init.d/postgresql restart
psql --command "ALTER USER postgres WITH PASSWORD 'qwerty';"
psql --command "CREATE EXTENSION postgis;"
echo "export LC_ALL=C.UTF-8" >> ~/.profile
echo "export LANG=C.UTF-8" >> ~/.profile
cp /etc/skel/.bashrc /home/postgres/.
cp /etc/skel/.profile /home/postgres/.
createdb datacube_cluster
