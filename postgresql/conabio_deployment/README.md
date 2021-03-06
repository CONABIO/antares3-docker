
Create some useful directories:

```
dir=/LUSTRE/MADMEX/docker_antares3/postgresql_volume_docker

mkdir $dir

git clone https://github.com/CONABIO/antares3-docker.git $dir/antares3-docker

mkdir -p $dir/etc/postgresql
mkdir -p $dir/var/log/postgresql
mkdir -p $dir/var/lib/postgresql
```

Build (outside of container):

```
cd $dir/antares3-docker/postgresql/conabio_deployment/
sudo docker build -t madmex/postgresql-antares3-datacube-my_image:v_my_version .
```

Mapping of directories on postgresql-datacube container:

`/etc/postgresql , /var/log/postgresql , /var/lib/postgresql` (backup of config, logs and databases )


`/home/postgres/conf/` (configurations as setup.sh and entrypoint.sh to use postgres as madmex_admin and can rw on LUSTRE)


Run command:

```
sudo docker run \
-v /LUSTRE/MADMEX/:/LUSTRE/MADMEX/ \
-v $dir/etc/postgresql:/etc/postgresql \
-v $dir/var/log/postgresql:/var/log/postgresql \
-v $dir/var/lib/postgresql:/var/lib/postgresql \
-v $dir/antares3-docker/postgresql/conabio_deployment/conf/:/home/postgres/conf/ \
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

and password in `conf/entrypoint.sh` 

Push to dockerhub:

```
sudo docker commit postgresql-conabio-cluster-container madmex/postgresql-antares3-datacube-conabio-cluster:v2

sudo docker push madmex/postgresql-antares3-datacube-conabio-cluster:v2
```

**Create some spatial indexes**

```
CREATE INDEX madmex_predictobject_gix ON public.madmex_predictobject USING GIST (the_geom);
CREATE INDEX madmex_trainobject_gix ON public.madmex_trainobject USING GIST (the_geom);
```

# Note:

If postgres container stopped then start it again, exec into it with postgres user and:

```
sudo /etc/init.d/postgresql start
```

# Note2:

Change `postgresql.conf` according to your settings:

```
sed -i 's/#work_mem = 4MB/work_mem = 1GB/g' /etc/postgresql/10/main/postgresql.conf
sed -i 's/#effective_io_concurrency = 1/effective_io_concurrency = 4/g' /etc/postgresql/10/main/postgresql.conf
```

And do a restart:

```
sudo /etc/init.d/postgresql restart
