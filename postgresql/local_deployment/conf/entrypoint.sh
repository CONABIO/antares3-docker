#!/bin/bash

useradd --shell /bin/bash postgres && echo 'postgres:qwerty' | chpasswd
echo "postgres ALL=(ALL:ALL) NOPASSWD:ALL" | (EDITOR="tee -a" visudo)
export HOME=/home/postgres
chown postgres:postgres -R /home/postgres/
chown postgres:postgres -R /tmp
chmod 750 /home/postgres
usermod -aG sudo postgres
