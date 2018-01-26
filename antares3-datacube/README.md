Directories on LUSTRE

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/datacube_ingest`

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/tmp_antares-3`

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/credentials`

Python libraries

`chmod +x /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/git/antares3-docker/conf/setup.sh`

Build of docker image

`sudo docker build -t antares3-datacube .`


Mapping of directories on antares3-datacube container:

`/home/madmex_user/datacube_ingest` (data)


`/tmp/` (intermediary results)

`/home/madmex_user/conf/` (configurations as setup.sh, .env and entrypoint.sh to use madmex_user as madmex_admin and can rw on LUSTRE)

Run command:

```
sudo docker run \
-v /LUSTRE/MADMEX/:/LUSTRE/MADMEX/ \
-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/datacube_ingest:/home/madmex_user/datacube_ingest \
-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/tmp_antares-3:/tmp/ \
-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/git/antares3-docker/antares3-datacube/conf/:/home/madmex_user/conf/ \
-v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/credentials:/home/madmex_user/credentials \
-e LOCAL_USER_ID=$(id -u madmex_admin) --name antares3-datacube-container --hostname antares3-datacube -p 2224:22 -p 8887:8887 \
-dit antares3-datacube  /bin/bash
```

Execute setup.sh

`sudo docker exec -u=madmex_user -it antares3-datacube-container /home/madmex_user/conf/setup.sh`
