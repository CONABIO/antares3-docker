# Set directory in LUSTRE:

```
dir=/LUSTRE/MADMEX/docker_antares3/conabio_cluster
```

# Create some directories:

```
mkdir -p $dir/tmp_docker_container
mkdir -p $dir/shared_volume_docker_container
mkdir -p $dir/home_madmex_user_conabio_docker_container_results
```

# Clone repo

```
git clone https://github.com/CONABIO/antares3-docker.git $dir/antares3-docker
```

# 1) Build docker image

```
MADMEX_VERSION=v3
ANTARES_DATACUBE_VERSION=v4
REPO_URL_MADMEX=madmex/conabio-deployment
REPO_URL_ANTARES=madmex/antares3-datacube
```

```
cd $dir/antares3-docker/antares3-datacube/conabio_deployment/

sudo docker build -t antares3-datacube:$ANTARES_DATACUBE_VERSION .
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
-dit antares3-datacube:$ANTARES_DATACUBE_VERSION /bin/bash
```

## Execute setup.sh

`sudo docker exec -u=madmex_user -it conabio-deployment /home/madmex_user/conf/setup.sh`


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


## Persist docker images

Commit changes to new image `$REPO_URL_MADMEX:$MADMEX_VERSION` and tag image `antares3-datacube:$ANTARES_DATACUBE_VERSION` to `madmex/antares3-datacube:$ANTARES_DATACUBE_VERSION`

```
sudo docker commit conabio-deployment $REPO_URL_MADMEX:$MADMEX_VERSION

sudo docker tag antares3-datacube:$ANTARES_DATACUBE_VERSION $REPO_URL_ANTARES:$ANTARES_DATACUBE_VERSION
```

Push images to dockerhub

```
sudo docker push $REPO_URL_MADMEX:$MADMEX_VERSION

sudo docker push $REPO_URL_ANTARES:$ANTARES_DATACUBE_VERSION
```

To download in parallel docker image use:

```
parallel-ssh -i -p 2 -t 0 -v -h nodos.txt -l madmex_admin "sudo docker pull madmex/conabio-deployment:v3"
```

where `nodos.txt`:

```
nodo1
nodo2
nodo3
nodo4
nodo5
nodo6
nodo7
```

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
pip3.6 install --user git+https://github.com/CONABIO/antares3.git@<here put branch of git> --upgrade --no-deps
```

# 4) Cluster deployment via docker-swarm


Open protocols and ports between the hosts
The following ports must be available. On some systems, these ports are open by default.

```
TCP port 2377 for cluster management communications
TCP and UDP port 7946 for communication among nodes
UDP port 4789 for overlay network traffic
```

If you plan on creating an overlay network with encryption (--opt encrypted), you also need to ensure ip protocol 50 (ESP) traffic is allowed.

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

To retrieve `<random token>` if you lost it, execute in node manager:

```
sudo docker swarm join-token worker
```

This last output need to be executed in every node that will be part of cluster. And we can see which nodes are in our cluster with:

```
sudo docker node ls
```

To leave the swarm execute in a node labeled as worker:

```
sudo docker swarm leave
```

To leave the swarm execute in a node labeled as manager:

```
sudo docker swarm leave --force
```

**Note: if a node left, then repeat lines of join in all nodes to have status Active in all nodes (including manager)**

**Note2: if manager left, then network will also dissappear then create again the network:**


**Next commands need to be executed in node manager (for example node 5)**

## Create overlay network

```
sudo docker network create -d overlay overnet
```

## Deploy services of scheduler and workers with dask & distributed and jupyerlab in scheduler

**Scale up**

Set dir:

```
dir=/LUSTRE/MADMEX/docker_antares3/conabio_cluster
MADMEX_VERSION=v3
REPO_URL_MADMEX=madmex/conabio-deployment
```


### Scheduler

Choose appropiate interface and branch of github of antares3 for scheduler in variable `interface`, `antares_branch` of  next command:

```
interface=eth2
antares_branch=develop
sudo docker service create --detach=false --name madmex-service-scheduler \
--network overnet --replicas 1 --env HDF5_USE_FILE_LOCKING=FALSE --env LOCAL_USER_ID=$(id -u madmex_admin) \
--env antares_branch=$antares_branch \
--mount type=bind,source=$dir/home_madmex_user_conabio_docker_container_results,destination=/home/madmex_user/results \
--mount type=bind,source=$dir/antares3-docker/antares3-datacube/conabio_deployment/conf/setup.sh,destination=/home/madmex_user/conf/setup.sh \
--mount type=bind,source=/LUSTRE/MADMEX/,destination=/LUSTRE/MADMEX/ \
--mount type=bind,source=$dir/shared_volume_docker_container,destination=/shared_volume \
-p 2222:22 -p 8786:8786 -p 8787:8787 -p 10000:10000  \
$REPO_URL_MADMEX:$MADMEX_VERSION /bin/bash -c "/home/madmex_user/.local/bin/pip3.6 install --user git+https://github.com/CONABIO/antares3.git@$antares_branch --upgrade --no-deps &&\
/home/madmex_user/.local/bin/antares init &&\
cd / && \
/home/madmex_user/.local/bin/jupyter lab --ip=0.0.0.0 --no-browser &\
cd ~ && /home/madmex_user/.local/bin/dask-scheduler --interface $interface --port 8786 --dashboard-address :8787 --scheduler-file /shared_volume/scheduler.json"
```


### Workers

Change interface, number of workers, memory limit and branch of github of antares3 according to your deployment in variables `replicas`, `interface`, `memory`, `antares_branch` of next command


```
replicas=2
interface=eth0
memory=6GB
antares_branch=develop
sudo docker service create --limit-memory $memory --detach=false --name madmex-service-worker \
--network overnet --replicas $replicas --env HDF5_USE_FILE_LOCKING=FALSE --env LOCAL_USER_ID=$(id -u madmex_admin) \
--env antares_branch=$antares_branch \
--mount type=bind,source=$dir/home_madmex_user_conabio_docker_container_results,destination=/home/madmex_user/results \
--mount type=bind,source=$dir/antares3-docker/antares3-datacube/conabio_deployment/conf/setup.sh,destination=/home/madmex_user/conf/setup.sh \
--mount type=bind,source=/LUSTRE/MADMEX/,destination=/LUSTRE/MADMEX/ \
--mount type=bind,source=$dir/shared_volume_docker_container,destination=/shared_volume \
$REPO_URL_MADMEX:$MADMEX_VERSION \
/bin/bash -c "/home/madmex_user/.local/bin/pip3.6 install --user git+https://github.com/CONABIO/antares3.git@$antares_branch --upgrade --no-deps &&\
/home/madmex_user/.local/bin/antares init &&\
cd ~ && \
/home/madmex_user/.local/bin/dask-worker --interface $interface \
--nprocs 1 --worker-port 8786 --nthreads 1 --no-dashboard \
--memory-limit $memory --death-timeout 60 --scheduler-file /shared_volume/scheduler.json"
```


### Notes (scale down and others...)

**Check nodes where services are deployed**

```
sudo docker service ps madmex-service-scheduler
```

```
sudo docker service ps madmex-service-worker
```

**Logging**

```
sudo docker service logs madmex-service-scheduler
```

```
sudo docker service logs madmex-service-worker
```

**Scale down**

To delete services of either scheduler or workers execute:

```
sudo docker service rm madmex-service-scheduler
```

```
sudo docker service rm madmex-service-worker
```

