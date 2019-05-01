To avoid having packages and dependencies different we use same image in docker hub to deploy k8s deployment and dummy cluster

And we change few things regarding permissions to write in LUSTRE...

```
sudo docker pull my_image:v_my_version
```

Make a few changes:

```
sudo docker run --user=root -e LOCAL_USER_ID=$(id -u madmex_admin) --name antares3-datacube-container_v8 --hostname antares3-datacube -dit my_image:v_my_version /bin/bash
sudo docker exec -it antares3-datacube-container_v8 bash
```

## Properly mount LUSTRE

```
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu 
```

change permissions:

```
chmod gou+x /usr/local/bin/gosu
```

Create next file:

```
nano /usr/local/bin/entrypoint.sh
```

```
#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback
USER_ID=${LOCAL_USER_ID:-9001}

echo "Starting with UID : $USER_ID"
useradd --shell /bin/bash -u $USER_ID -o -c "" -m madmex_user_conabio && echo 'madmex_user_conabio:qwerty' | chpasswd
echo "madmex_user_conabio ALL=(ALL:ALL) NOPASSWD:ALL" | (EDITOR="tee -a" visudo)
export HOME=/home/madmex_user_conabio
chown madmex_user:madmex_user_conabio -R /home/madmex_user_conabio/
chown madmex_user:madmex_user_conabio -R /tmp
chmod 750 /home/madmex_user_conabio
usermod -aG sudo madmex_user_conabio

sudo chmod -R gou+wrx /shared_volume

sudo chmod -R gou+rwx /home/madmex_user_conabio/

sudo chmod -R gou+rwx /tmp/

#create .jupyter directory

#copy /home/madmex_user/.antares config to /home/madmex_user_conabio

#copy /home/madmex_user/.datacube.config to /home/madmex_user_conabio

mkdir /home/madmex_user_conabio/.jupyter
sudo cp -r /home/madmex_user/.antares /home/madmex_user_conabio/
sudo chown -h madmex_user_conabio:madmex_user_conabio /home/madmex_user_conabio/.antares
sudo cp -r /home/madmex_user/.datacube.conf /home/madmex_user_conabio/
sudo chown -h madmex_user_conabio:madmex_user_conabio /home/madmex_user_conabio/.datacube.conf

#copy to shared_volume

mkdir /shared_volume/.jupyter
sudo cp -r /home/madmex_user/.jupyter/jupyter_notebook_config.py /shared_volume/.jupyter/
sudo chown -Rh madmex_user_conabio:madmex_user_conabio /shared_volume/.jupyter/jupyter_notebook_config.py

#change owner:
sudo chown -Rh madmex_user_conabio:madmex_user_conabio /home/madmex_user_conabio/.jupyter/
#create symbolic link to /shared_volume/.jupyter:
ln -sf /shared_volume/.jupyter/jupyter_notebook_config.py /home/madmex_user_conabio/.jupyter/jupyter_notebook_config.py
#change owner:
sudo chown -Rh madmex_user_conabio:madmex_user_conabio /home/madmex_user_conabio/.jupyter/jupyter_notebook_config.py

#edit
sed -i "s/c.NotebookApp.certfile = .*/#c.NotebookApp.certfile =/" /shared_volume/.jupyter/jupyter_notebook_config.py

sed -i "s/c.NotebookApp.keyfile = .*/#c.NotebookApp.keyfile =/" /shared_volume/.jupyter/jupyter_notebook_config.py

#some missing files:
cp /etc/skel/.profile /home/madmex_user_conabio/.
cp /etc/skel/.bashrc /home/madmex_user_conabio/.

exec /usr/local/bin/gosu madmex_user_conabio "$@"
```

change permissions:

```
chmod gou+x /usr/local/bin/entrypoint.sh
```

exit of docker container, commit changes to a image and then push to dockerhub

```
sudo docker commit antares3-datacube-container_v8 madmex/my_image-conabio-cluster:v_my_version
sudo docker push madmex/my_image-conabio-cluster:v_my_version
sudo docker stop antares3-datacube-container_v8
sudo docker rm antares3-datacube-container_v8
```

## Run:

```
sudo docker run -v /LUSTRE/MADMEX/:/LUSTRE/MADMEX/ -v /LUSTRE/MADMEX/docker_antares/antares3-k8s-cluster-dependencies_v8/home_madmex_user_conabio_docker_container_results/:/home/madmex_user_conabio/results -v /LUSTRE/MADMEX/docker_antares/antares3-k8s-cluster-dependencies_v8/tmp_docker_container:/tmp -v /LUSTRE/MADMEX/docker_antares/antares3-k8s-cluster-dependencies_v8/shared_volume_docker_container:/shared_volume -e LOCAL_USER_ID=$(id -u madmex_admin) -w=/home/madmex_user_conabio --name antares3-conabio-cluster_v8 --hostname antares3-datacube -p 2224:22 -p 9796:8786 -p 8887:8887 -p 9797:8787 -p 9798:8788 -p 9789:8789 -p 9999:9999 --entrypoint=/usr/local/bin/entrypoint.sh -dit madmex/my_image-conabio-cluster:v_my_version /bin/bash
```

Enter and restart ssh to login via ssh:

```
sudo docker exec -u=madmex_user_conabio -it antares3-conabio-cluster_v8 bash

sudo service ssh restart
```

We can edit .antares either:

here:

```
/home/madmex_user_conabio/.antares
```

or here:

```
/shared_volume/.antares
```

same apply to ```.datacube.conf``` or ```.jupyter/jupyter_notebook_config.py```


