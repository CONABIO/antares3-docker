`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/etc/postgresql`

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/var/log/postgresql`

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/var/lib/postgresql`

`chmod +x /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/git/antares3-docker/conf/setup.sh`

`sudo docker build -t antares-image .`

`sudo docker run -v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/datacube_ingest:/home/madmex_user/datacube_ingest -v /LUSTRE/MADMEX/:/LUSTRE/MADMEX/ -e LOCAL_USER_ID=$(id -u madmex_admin) --name antares-container --hostname datacube-madmex -p 2224:22 -p 2345:5432 -p 8887:8887 -v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/etc/postgresql:/etc/postgresql -v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/var/log/postgresql:/var/log/postgresql -v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/var/lib/postgresql:/var/lib/postgresql -v /tmp/:/tmp/ -v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/git/antares3-docker/conf/:/home/madmex_user/conf/ -dit antares-image /bin/bash`

`sudo docker exec -u=madmex_user -it antares-container /home/madmex_user/conf/setup.sh`
