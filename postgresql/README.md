Clone: https://github.com/CONABIO/antares3-docker.git into `/LUSTRE/MADMEX/docker_antares/postgresql_volume_docker`

Create some useful directories:

```
dir=/LUSTRE/MADMEX/docker_antares/postgresql_volume_docker

sudo git clone https://github.com/CONABIO/antares3-docker.git $dir/antares3-docker

chmod -R gou+wrx $dir/antares3-docker

sudo mkdir $dir
sudo mkdir -p $dir/etc/postgresql
sudo mkdir -p $dir/var/log/postgresql
sudo mkdir -p $dir/var/lib/postgresql
chmod -R gou+wrx $dir/*
```

Build (outside of container):

```
sudo docker build -t madmex/postgresql-antares3-datacube-conabio-cluster:v1 .
```

Mapping of directories on postgresql-datacube container:

`/etc/postgresql , /var/log/postgresql , /var/lib/postgresql` (backup of config, logs and databases )


`/home/postgres/conf/` (configurations as setup.sh and entrypoint.sh to use postgres as madmex_admin and can rw on LUSTRE)


Run command:

```
dir=/LUSTRE/MADMEX/docker_antares/postgresql_volume_docker/


sudo docker run \
-v /LUSTRE/MADMEX/:/LUSTRE/MADMEX/ \
-v $dir/etc/postgresql:/etc/postgresql \
-v $dir/var/log/postgresql:/var/log/postgresql \
-v $dir/var/lib/postgresql:/var/lib/postgresql \
-v $dir/antares3-docker/postgresql/conf/:/home/postgres/conf/ \
-w /home/postgres \
-e LOCAL_USER_ID=$(id -u madmex_admin) -p 2225:22 -p 5432:5432 --name postgresql-conabio-cluster-container --hostname postgresql-datacube \
-dit madmex/postgresql-antares3-datacube-conabio-cluster:v1 /bin/bash
```

Execute setup.sh

`
sudo docker exec -u=postgres -it postgresql-conabio-cluster-container /home/postgres/conf/setup.sh
`

Enter and restart `ssh`

```
sudo docker exec -u=postgres -it postgresql-conabio-cluster-container  bash

sudo service ssh restart
```

to login:

`
ssh -p 2225 postgres@nodo5.conabio.gob.mx
`


