`sudo docker build -t antares-image .`

`sudo docker run -v /LUSTRE/MADMEX/:/LUSTRE/MADMEX/ -e LOCAL_USER_ID=$(id -u madmex_admin) --name antares-container --hostname datacube-madmex -p 2224:22 -p 2345:5432 -p 8887:8887 -v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/postgres_volume_docker/:/etc/postgresql -v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/postgres_volume_docker/:/var/log/postgresql -v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/postgres_volume_docker/:/var/lib/postgresql -v /tmp/:/tmp/ -v /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/conf/:/home/madmex_user/conf/ -dit antares-image /bin/bash`

`sudo docker exec -it antares-container /bin/bash`

`su - madmex_user`

`cp /setup.sh .`

`chmod +x setup.sh`

`./setup.sh`
