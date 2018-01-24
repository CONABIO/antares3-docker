Directories on LUSTRE

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/etc/postgresql`

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/var/log/postgresql`

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/var/lib/postgresql`

Postgres and python libraries

`chmod +x /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/git/antares3-docker/conf/setup.sh`

Build of docker image

`sudo docker build -t antares-image .`


Mapping of directories on antares-container:

`/home/madmex_user/datacube_ingest` (data)

`/etc/postgresql , /var/log/postgresql , /var/lib/postgresql` (backup of config, logs and databases )

`/tmp/` (intermediary results)

`/home/madmex_user/conf/` (configurations as setup.sh, .env and entrypoint.sh to use madmex_user and postgres as madmex_admin so they can rw on LUSTRE)

```
sudo docker run \

-v /LUSTRE/MADMEX/:/LUSTRE/MADMEX/ \

-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/datacube_ingest:/home/madmex_user/datacube_ingest \

-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/etc/postgresql:/etc/postgresql \

-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/var/log/postgresql:/var/log/postgresql \

-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/var/lib/postgresql:/var/lib/postgresql \

-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/tmp/:/tmp/ \

-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/git/antares3-docker/conf/:/home/madmex_user/conf/ \

-e LOCAL_USER_ID=$(id -u madmex_admin) --name antares-container --hostname datacube-madmex -p 2224:22 -p 2345:5432 -p 8887:8887 \

-dit antares-image /bin/bash
```

Execute setup.sh

`sudo docker exec -u=madmex_user -it antares-container /home/madmex_user/conf/setup.sh`
