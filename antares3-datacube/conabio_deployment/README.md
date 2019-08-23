# Set directory in LUSTRE:

```
dir=/LUSTRE/MADMEX/docker_antares3/conabio_cluster
```

# Create some directories:

```
mkdir -p $dir/tmp_docker_container
mkdir -p $dir/shared_volume_docker_container
```

# Clone repo

```
git clone https://github.com/CONABIO/antares3-docker.git $dir/antares3-docker
```

# Build docker image

```
cd $dir/antares3-docker/antares3-datacube/conabio_deployment/

sudo docker build -t antares3-datacube:v2 .
```

# Docker run

```
sudo docker run \
-v /LUSTRE/MADMEX/:/LUSTRE/MADMEX/ \
-v $dir/home_madmex_user_conabio_docker_container_results:/home/madmex_user/results \
-v $dir/shared_volume_docker_container:/shared_volume \
-v $dir/antares3-docker/antares3-datacube/conabio_deployment/conf/setup.sh:/home/madmex_user/conf/setup.sh \
-e LOCAL_USER_ID=$(id -u madmex_admin) --name conabio-deployment --hostname antares3-datacube -p 2222:22 -p 8706:8786 -p 8707:8787 \
-p 8708:8788 -p 8709:8789 -p 10000:10000 \
-dit antares3-datacube:v2 /bin/bash
```

# Config files

We can edit ```.antares``` either:

here:

```
/home/madmex_user/.antares
```

or here:

```
/shared_volume/.antares
```

same apply to ```.datacube.conf``` or ```.jupyter/jupyter_notebook_config.py```


Datacube and MADMex instalations need configuration files. The contents of these files should follow the patterns.

```.datacube.conf```:

```
[user]
default_environment: datacube
#default_environment: s3aio_env

[datacube]
db_hostname: nodo5
db_database: datacube_cluster_2
db_username: madmex_user
db_password: qwerty

execution_engine.use_s3: False

[s3aio_env]
db_hostname: nodo5
db_database: datacube_cluster_2
db_username: madmex_user
db_password: qwerty

#index_driver: s3aio_index

execution_engine.use_s3: False

```

```.antares```:

```
# Django settings
SECRET_KEY=<key>
DEBUG=True
DJANGO_LOG_LEVEL=DEBUG
ALLOWED_HOSTS=
# Database
DATABASE_NAME=datacube_cluster
DATABASE_USER=madmex_user
DATABASE_PASSWORD=qwerty
DATABASE_HOST=nodo5
DATABASE_PORT=5432
# Datacube
SERIALIZED_OBJECTS_DIR=/home/madmex_user/datacube_ingest/serialized_objects/
INGESTION_PATH=/home/madmex_user/datacube_ingest
#DRIVER=s3aio
DRIVER='NetCDF CF'
#INGESTION_BUCKET=datacube-s2-jalisco-test
# Query and download
USGS_USER=<username>
USGS_PASSWORD=<password>
SCIHUB_USER=
SCIHUB_PASSWORD=
# Misc
BIS_LICENSE=<license>
TEMP_DIR=/shared_volume/temp
SEGMENTATION_BUCKET=<name of bucket>
```

# Execute setup.sh

`sudo docker exec -u=madmex_user -it conabio-deployment /home/madmex_user/conf/setup.sh`


# Jupyterlab

To init jupyter lab ssh into container and execute jupyter lab cmd:

```
ssh -o ServerAliveInterval=60 -p 2222 madmex_user@<node of conabio>
cd /
jupyter lab --ip=0.0.0.0 --no-browser &
```

# Use credentials of AWS with environmental variables: 

**avoid creating/using .aws/credentials file** instead work with **environmental variables**

```
export AWS_ACCESS_KEY_ID=<my_access_key_id_aws>
export AWS_SECRET_ACCESS_KEY=<my_secret_access_key_aws>
```

# Init antares3 & datacube


```
antares init #make sure .antares file point's to DB properly

datacube -v system init #make sure .datacube.conf file point's to DB properly
```

**Create some spatial indexes**

```
psql -U postgres -d antares_datacube -h <conabio's node> #check node where postgresql container is deployed
CREATE INDEX madmex_predictobject_gix ON public.madmex_predictobject USING GIST (the_geom);
CREATE INDEX madmex_trainobject_gix ON public.madmex_trainobject USING GIST (the_geom);
```

**Don't forget to re install antares3 every time you change code:**

```
pip3 install --user git+https://github.com/CONABIO/antares3.git@<here put branch of git> --upgrade --no-deps
```

# Dask scheduler

```
dask-scheduler --port 8786 --bokeh-port 8787 --scheduler-file /shared_volume/scheduler.json
```

