Directories on LUSTRE

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker_2/datacube_ingest`

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker_2/tmp_antares-3`

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker_2/credentials`

Python libraries

`chmod +x /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/git/antares3-docker/antares3-datacube/conf/setup.sh`

Build of docker image

`sudo docker build -t antares3-datacube .`


Mapping of directories on antares3-datacube container:

`/home/madmex_user/datacube_ingest` (data)


`/tmp/` (intermediary results)

`/home/madmex_user/conf/` (configurations as setup.sh, .env and entrypoint.sh to use madmex_user as madmex_admin and can rw on LUSTRE)

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
TEMP_DIR=/LUSTRE/MADMEX/tasks/2018_tasks/belize_guyana/escenas/suriname/
```

Run command:

```
sudo docker run \
-v /LUSTRE/MADMEX/:/LUSTRE/MADMEX/ \
-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker_2/datacube_ingest:/home/madmex_user/datacube_ingest \
-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker_2/tmp_antares-3:/tmp/ \
-v <directory that contains datacube conf file>/.datacube.conf:/home/madmex_user/conf/.datacube.conf \
-v <directory that contains antares conf file>/.env:/home/madmex_user/conf/.antares \
-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/git/antares3-docker/antares3-datacube/conf/setup.sh:/home/madmex_user/conf/setup.sh \
-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/credentials:/home/madmex_user/credentials \
-e LOCAL_USER_ID=$(id -u madmex_admin) --name antares3-datacube-container --hostname antares3-datacube -p 2224:22 -p 9796:8786 -p 8887:8887 \
-p 9797:8787 -p 9798:8788 -p 9789:8789 -p 9999:9999 \
-dit antares3-datacube  /bin/bash
```

Execute setup.sh

`sudo docker exec -u=madmex_user -it antares3-datacube-container /home/madmex_user/conf/setup.sh`


To init jupyter lab first create a configuration file with:

`jupyter notebook --generate-config`

Select port of your preference, for example 9999:

`sed -i 's/#c.NotebookApp.port = .*/c.NotebookApp.port = 9999/' ~/.jupyter/jupyter_notebook_config.py`

and init jupyter lab with:

`jupyter lab --ip=0.0.0.0 --no-browser`

Also you can configure aws security credentials using aws config cmd line:

`aws config`

and create `~/.aws/config` with proper content:

`
[default]
aws_access_key_id=
aws_secret_access_key=
`
