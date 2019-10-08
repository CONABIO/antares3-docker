
# Set local directory, create it and clone repo:

```
dir=/Users/<miuser>/Documents/postgresql_volume_docker
mkdir $dir

git clone https://github.com/CONABIO/antares3-docker.git $dir/antares3-docker

mkdir -p $dir/etc/postgresql
mkdir -p $dir/var/log/postgresql
mkdir -p $dir/var/lib/postgresql
```

Build (outside of container):

```
cd $dir/antares3-docker/postgresql

docker build -t madmex/postgresql-madmex-local:v8 .
```

Mapping of directories on postgresql-datacube container:

`/etc/postgresql , /var/log/postgresql , /var/lib/postgresql` (backup of config, logs and databases )


`/home/postgres/conf/` (configurations as setup.sh and entrypoint.sh to use postgres as madmex_admin and can rw on LUSTRE)


# Docker run

```
docker run -v $dir/etc/postgresql:/etc/postgresql \
-v $dir/var/log/postgresql:/var/log/postgresql \
-v $dir/var/lib/postgresql:/var/lib/postgresql \
-v $dir/antares3-docker/postgresql/local_deployment/conf/:/home/postgres/conf/ \
-w /home/postgres \
-p 2225:22 -p 5432:5432 --name postgresql-local --hostname postgresql-madmex \
-dit madmex/postgresql-madmex-local:v8 /bin/bash
```

Execute entrypoint.sh & setup.sh

```
docker exec -it postgresql-local /usr/local/bin/entrypoint.sh
docker exec -u=postgres -it postgresql-local /home/postgres/conf/setup.sh
```

Enter and restart `ssh`

```
sudo docker exec -u=postgres -it postgresql-local  bash

sudo service ssh restart
```

to login:

`
ssh -p 2225 postgres@<local node>
`

and password in `conf/entrypoint.sh` 

**Create some spatial indexes**

to enter to local database: (see [conf/setup.sh](conf/setup.sh) for credentials)

```
psql -h localhost -d <databasename> -U postgres
```

```
CREATE INDEX madmex_predictobject_gix ON public.madmex_predictobject USING GIST (the_geom);
CREATE INDEX madmex_trainobject_gix ON public.madmex_trainobject USING GIST (the_geom);
```

# Note:

If postgres container stopped then start it again, exec into it with postgres user and:

```
sudo /etc/init.d/postgresql start
```
