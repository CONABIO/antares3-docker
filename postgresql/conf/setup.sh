#!/bin/bash
sudo service ssh restart
sudo apt-get install -y  \
postgresql-9.5 \
postgresql-contrib-9.5 \
postgresql-client-9.5
sudo /etc/init.d/postgresql start
echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.5/main/pg_hba.conf
echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf
sudo /etc/init.d/postgresql restart
#createdb -O postgres postgres
#psql --command "ALTER USER postgres WITH PASSWORD 'qwerty';"
cp /etc/skel/.bashrc /home/postgres/.
cp /etc/skel/.profile /home/postgres/.
createdb datacube_cluster