Directories on LUSTRE

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/etc/postgresql`

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/var/log/postgresql`

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/var/lib/postgresql`

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/tmp_postgresql/`

Mapping of directories on postgresql-datacube container:

`/etc/postgresql , /var/log/postgresql , /var/lib/postgresql` (backup of config, logs and databases )

`/tmp/` (intermediary results)

`/home/postgres/conf/` (configurations as setup.sh and entrypoint.sh to use postgres as madmex_admin and can rw on LUSTRE)

Postgres libraries

`chmod +x /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/git/antares3-docker/postgresql/conf/setup.sh`

Run command:

```
sudo docker run \
-v /LUSTRE/MADMEX/:/LUSTRE/MADMEX/ \
-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/etc/postgresql:/etc/postgresql \
-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/var/log/postgresql:/var/log/postgresql \
-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/var/lib/postgresql:/var/lib/postgresql \
-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/git/antares3-docker/postgresql/conf/:/home/postgres/conf/ \
-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/tmp_postgresql/:/tmp/ \
-e LOCAL_USER_ID=$(id -u madmex_admin) -p 2226:22 -p 5432:5432 --name postgresql-datacube-container --hostname postgresql-datacube \
-dit postgresql-antares3-datacube /bin/bash
```

Execute setup.sh

`sudo docker exec -u=postgres -it postgresql-datacube-container /home/postgres/conf/setup.sh`
