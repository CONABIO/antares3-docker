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

# 1) Build docker image

```
cd $dir/antares3-docker/antares3-datacube/conabio_deployment/

sudo docker build -t antares3-datacube:v2 .
```

## Docker run

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

## Config files

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

## Execute setup.sh

`sudo docker exec -u=madmex_user -it conabio-deployment /home/madmex_user/conf/setup.sh`


# 3) Some notes

## Use credentials of AWS with environmental variables: 

**avoid creating/using .aws/credentials file** instead work with **environmental variables**

```
export AWS_ACCESS_KEY_ID=<my_access_key_id_aws>
export AWS_SECRET_ACCESS_KEY=<my_secret_access_key_aws>
```

## Init antares3 & datacube


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

# 4) Cluster deployment via docker-swarm

## Set manager and workers of cluster

Choose a node in conabio, for example node5, then:

```
sudo docker swarm init --advertise-addr <ip of node5>
```

Last command will output something like:

```
sudo docker swarm join \
--token <random token> \
<ip of node5>:<random port>
```

This last output need to be executed in every node that will be part of cluster. And we can see which nodes are in our cluster with:

```
sudo docker node ls
```

## Create overlay network

Next commands need to be executed in node manager (for example node 5)

```
sudo docker network create -d overlay overnet
```

## Deploy services of scheduler and workers with dask & distributed and jupyerlab in scheduler

Set dir:

```
dir=/LUSTRE/MADMEX/docker_antares3/conabio_cluster
```


### Scheduler

Choose appropiate interface for scheduler in last line of next command:

```
sudo docker service create --detach=false --name madmex-service-scheduler \
--network overnet --replicas 1 --env LOCAL_USER_ID=$(id -u madmex_admin) \
--mount type=bind,source=$dir/home_madmex_user_conabio_docker_container_results,destination=/home/madmex_user/results \
--mount type=bind,source=$dir/antares3-docker/antares3-datacube/conabio_deployment/conf/setup.sh,destination=/home/madmex_user/conf/setup.sh \
--mount type=bind,source=/LUSTRE/MADMEX/,destination=/LUSTRE/MADMEX/ \
--mount type=bind,source=$dir/shared_volume_docker_container,destination=/shared_volume \
-p 8786:8786 -p 8787:8787 -p 10000:10000  \
madmex/conabio-deployment:v1 \
/bin/bash -c "cd / && /home/madmex_user/.local/bin/jupyter lab --ip=0.0.0.0 --no-browser & cd ~ && /home/madmex_user/.local/bin/dask-scheduler --interface eth2 --port 8786 --dashboard-address :8787 --scheduler-file /shared_volume/scheduler.json"
```


### Workers

Choose interface, number of workers and memory limit and change them in appropiate place of next command

```
sudo docker service create --detach=false --name madmex-service-worker \
--network overnet --replicas 2 --env LOCAL_USER_ID=$(id -u madmex_admin) \
--mount type=bind,source=$dir/home_madmex_user_conabio_docker_container_results,destination=/home/madmex_user/results \
--mount type=bind,source=$dir/antares3-docker/antares3-datacube/conabio_deployment/conf/setup.sh,destination=/home/madmex_user/conf/setup.sh \
--mount type=bind,source=/LUSTRE/MADMEX/,destination=/LUSTRE/MADMEX/ \
--mount type=bind,source=$dir/shared_volume_docker_container,destination=/shared_volume \
madmex/conabio-deployment:v1 \
/bin/bash -c "cd ~ && /home/madmex_user/.local/bin/dask-worker --interface eth0 --nprocs 1 --worker-port 8786 --nthreads 1 --no-bokeh --memory-limit 6GB --death-timeout 60 --scheduler-file /shared_volume/scheduler.json"
```

### Notes

To check services:

```
sudo docker service ps madmex-service-scheduler
```

```
sudo docker service ps madmex-service-worker
```

To delete services of either scheduler or workers execute:

```
sudo docker service rm madmex-service-scheduler
```

```
sudo docker service rm madmex-service-worker
```

