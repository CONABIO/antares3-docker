# 1. Set working directory

```
dir=/home/miuser/
```
# 2. Clone this repo

```
git clone https://github.com/CONABIO/antares3-docker.git $dir/antares3-docker
````

# 3. Build docker image and push it to dockerhub

Using image previously built in [conabio_deployment](https://github.com/CONABIO/antares3-docker/tree/master/antares3-datacube/conabio_deployment#persist-docker-images) change directory and give permissions to execute `conf.sh`

```
cd $dir/antares3-docker/antares3-datacube/travis
chmod gou+x conf.sh
```

Run docker container and execute `conf.sh`:

```
sudo docker run -v $(pwd):/data --name travis-madmex --hostname antares3-datacube -dit madmex/antares3-datacube:v2 /bin/bash
sudo docker exec -it -u=madmex_user travis-madmex bash /data/conf.sh
```

After execution of `conf.sh` commit and push docker image to docker hub:

```
sudo docker commit travis-madmex madmex/travis_antares3:v1
sudo docker push madmex/travis_antares3:v1
```

# 4. `.travis.yml`

```
services:
  - docker

before_script:
  - docker pull madmex/travis_antares3:v1
env:
  - antares_branch=$TRAVIS_BRANCH datacube_branch=develop
  
script:
  - docker run --rm -it -e antares_branch=$antares_branch -e datacube_branch=$datacube_branch madmex/travis_antares3:v1 /bin/bash -c 'git clone --single-branch -b $antares_branch https://github.com/CONABIO/antares3.git /home/madmex_user/branch && /home/madmex_user/branch/travis_setup.py && sudo service postgresql start && sudo -u postgres createdb datacube && source /home/madmex_user/.profile && pip3.6 install --user git+https://github.com/opendatacube/datacube-core.git@$datacube_branch --no-deps --upgrade && datacube system init && cd /home/madmex_user/branch && python3.6 setup.py test' 

after_success:
  - pip install -r docs/requirements.txt 
  - git checkout -b gh-pages origin/gh-pages
  - rm -rf *
  - git checkout develop docs madmex
  - git reset HEAD
  - cd docs
  - make html
  - cd ..
  - mv -f docs/_build/html/* .
  - touch .nojekyll
  - rm -rf madmex docs

deploy:
  provider: pages
  skip-cleanup: true
  github-token: $GH_TOKEN
  keep-history: true
  on:
    branch: develop

warnings_are_errors: true

notifications:
email: false
```

