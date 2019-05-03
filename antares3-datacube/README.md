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

# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback
USER_ID=${LOCAL_USER_ID:-9001}

echo "Starting with UID : $USER_ID"
export HOME=/home/madmex_user
chown madmex_user:madmex_user -R /tmp
usermod -aG sudo madmex_user

sudo chmod -R gou+wrx /shared_volume

sudo chmod -R gou+rwx /home/madmex_user/

sudo chmod -R gou+rwx /tmp/

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

sed -i "s/c.NotebookApp.password = .*/c.NotebookApp.password = u'<misha>'/" /shared_volume/.jupyter/jupyter_notebook_config.py

#some missing files:

exec /usr/local/bin/gosu madmex_user "$@"
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
dir=/LUSTRE/MADMEX/docker_antares/antares3-k8s-cluster-dependencies_v8

sudo docker run -v /LUSTRE/MADMEX/:/LUSTRE/MADMEX/ \
-v $dir/home_madmex_user_conabio_docker_container_results/:/home/madmex_user/results \
-v $dir/tmp_docker_container:/tmp \
-v $dir/shared_volume_docker_container:/shared_volume \
-e LOCAL_USER_ID=$(id -u madmex_admin) --name antares3-conabio-cluster_v8_scheduler \
--hostname antares3-datacube -p 2224:22 -p 9796:8786 -p 8887:8887 -p 9797:8787 \
-p 9798:8788 -p 9789:8789 -p 9999:9999 \
--entrypoint=/usr/local/bin/entrypoint.sh \
-dit madmex/antares3-conabio-cluster:v8 /bin/bash
```

Enter and restart ssh to login via ssh:

```
sudo docker exec -u=madmex_user -it antares3-conabio-cluster_v8 bash
sudo service ssh restart
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

To login via ssh just do a:

```
ssh -o ServerAliveInterval=60 -p 2224 madmex_user@nodo5
```

and same password :)

To login to jupyterlab exec to docker container and then:

```
jupyter lab --ip=0.0.0.0 --no-browser &
```

**Don't forget to re install antares3 every time you change code:

```
pip3 install --user git+https://github.com/CONABIO/antares3.git@develop --upgrade --no-deps && /home/madmex_user/.local/bin/antares init
```
