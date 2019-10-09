To avoid having different packages and dependencies we use same image in docker hub to deploy k8s deployment and dummy cluster locally without permissions to write to LUSTRE file system. This docker image uses a `bionic` version of ubuntu.


# Run docker container

```
docker run --user=root --name antares3-datacube-container_v8 --hostname antares3-datacube -dit madmex/antares3-k8s-cluster-dependencies:v8 /bin/bash
```


# Enter & create next file:

```
docker exec -it antares3-datacube-container_v8 bash
nano /usr/local/bin/entrypoint.sh
```

```
#!/bin/bash

export HOME=/home/madmex_user
chown madmex_user:madmex_user -R /tmp
chown madmex_user:madmex_user -R /shared_volume
chown madmex_user:madmex_user -R /home/madmex_user 
usermod -aG sudo madmex_user

#create .jupyter directory

#copy to shared_volume

mkdir /shared_volume/.jupyter
sudo cp -r /home/madmex_user/.jupyter/jupyter_notebook_config.py /shared_volume/.jupyter/
sudo chown -Rh madmex_user:madmex_user /shared_volume/.jupyter/jupyter_notebook_config.py


#create symbolic link to /shared_volume/.jupyter:
ln -sf /shared_volume/.jupyter/jupyter_notebook_config.py /home/madmex_user/.jupyter/jupyter_notebook_config.py


#edit
sed -i "s/c.NotebookApp.certfile = .*/#c.NotebookApp.certfile =/" /shared_volume/.jupyter/jupyter_notebook_config.py

sed -i "s/c.NotebookApp.keyfile = .*/#c.NotebookApp.keyfile =/" /shared_volume/.jupyter/jupyter_notebook_config.py

sed -i "s/c.NotebookApp.password = .*/c.NotebookApp.password = u'sha1:e47d7d0c0c23:22db3ffa5484ff0c18234217279b117a525a337a'/" /shared_volume/.jupyter/jupyter_notebook_config.py

#some configs for antares & datacube
ln -sf /shared_volume/.antares ~/.antares
ln -sf /shared_volume/.datacube.conf ~/.datacube.conf

echo 'export GDAL_DATA=/usr/share/gdal/' >> /home/madmex_user/.profile

```

change permissions:

```
chmod gou+x /usr/local/bin/entrypoint.sh
```

exit of docker container, commit changes to a image and then (optionally) push it to dockerhub

```
docker commit antares3-datacube-container_v8 madmex/madmex_local:v8

docker push madmex/madmex_local:v8 #(optional)

docker stop antares3-datacube-container_v8

docker rm antares3-datacube-container_v8
```

# Set local directory and create it:

```
dir=/Users/<miuser>/Documents/antares3-datacube-volume-docker
mkdir $dir
```

# Docker run

```
docker run -v /Volumes/MADMEX:/LUSTRE/MADMEX \
-v $dir/home_madmex_user_conabio_docker_container_results/:/home/madmex_user/results \
-v $dir/tmp_docker_container:/tmp \
-v $dir/shared_volume_docker_container:/shared_volume \
--name antares3-local_scheduler \
--hostname antares3-datacube -p 2224:22 -p 8706:8786 -p 8707:8787 \
-p 8708:8788 -p 8709:8789 -p 9999:9999 \
-dit madmex/madmex_local:v8 /bin/bash
```

Execute `entrypoint.sh`

```
docker exec -it antares3-local_scheduler /usr/local/bin/entrypoint.sh
```

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
db_hostname: <local node>
db_database: datacube_cluster_2
db_username: madmex_user
db_password: qwerty

execution_engine.use_s3: False

[s3aio_env]
db_hostname: <local node>
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
DATABASE_HOST=<local node>
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


To login via ssh restart ssh service `sudo service ssh restart` inside of container and then just do a:

```
ssh -o ServerAliveInterval=60 -p 2222 madmex_user@<local node>
```

and same password :)

To login to jupyterlab exec to docker container and then:

```
cd /
jupyter lab --ip=0.0.0.0 --no-browser &
```

## acces to jupyterlab using:

```
<node where jupyterlab is deployed>:9999
```

and login with password :)


## Use credentials of AWS with environmental variables: 

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
psql -U postgres -d antares_datacube -h <node> #check node where postgresql container is deployed
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

# Bash script to launch dask workers:


`launch_dask_workers.sh`

```
#!/bin/bash


dir=/Users/<miuser>/Documents/antares3-datacube-volume-docker

for i in $(seq $1);do docker run --name antares3-local_worker_$i -v $dir/shared_volume_docker_container:/shared_volume --hostname antares3-datacube -p 970$i:8786 -dit madmex/madmex_local:v8 /bin/bash;done

for i in $(seq $1);do docker exec -it antares3-local_worker_$i /usr/local/bin/entrypoint.sh;done

for i in $(seq $1);do docker exec -it -u=madmex_user antares3-local_worker_$i /bin/bash -c 'pip3 install --user git+https://github.com/CONABIO/antares3.git@<here put branch of git> --upgrade --no-deps && /home/madmex_user/.local/bin/antares init';done

for i in $(seq $1);do docker exec -d -u=madmex_user antares3-local_worker_$i dask-worker --nprocs 1 --worker-port 8786 --nthreads 1 --no-bokeh --memory-limit 4GB --death-timeout 60 --scheduler-file /shared_volume/scheduler.json;done

```

Execute bash script and select number of dask workers:

`bash launch_dask_workers.sh <number of dask workers>`
