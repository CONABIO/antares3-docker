Creamos los siguientes directorios en LUSTRE:

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/etc/postgresql`

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/var/log/postgresql`

`mkdir -p /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/datacube_directories_mapping_docker/postgres_volume_docker/var/lib/postgresql`

Instalación de postgres y librerías de python

`chmod +x /LUSTRE/MADMEX/tasks/2018_tasks/datacube_madmex/git/antares3-docker/conf/setup.sh`

Construcción de docker image:

`sudo docker build -t antares-image .`


Mapeo de directorios en contenedor antares-container:

/home/madmex_user/datacube_ingest (para datos)
/etc/postgresql , /var/log/postgresql , /var/lib/postgresql (para backup de config, logs and databases )
/tmp/ (para resultados intermedios)
/home/madmex_user/conf/ (para configuraciones como el setup.sh , el .env y el entrypoint.sh para enmascarar usuarios madmex_user y postgres y puedan leer-escribir a LUSTRE como madmex_admin)

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

`sudo docker exec -u=madmex_user -it antares-container /home/madmex_user/conf/setup.sh`
