FROM ubuntu:16.04
MAINTAINER Loic Dutrieux

EXPOSE 22 5432 8887

RUN apt-get -qq update && apt-get install --fix-missing -y --force-yes --no-install-recommends \
	locales

# Set the locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8     


# install basic packages
RUN apt-get install --fix-missing -y --force-yes --no-install-recommends \
	openssh-server \
	openssl \
	sudo \
	wget \
	nano \
	software-properties-common \
	python-software-properties \
	git \
	vim \
	vim-gtk \
	htop \
	build-essential \
	libssl-dev \
	libffi-dev \
	python3-dev \
	cmake \
	python-pip \
	python3-pip \
	python-setuptools \
	python3-setuptools \
	ca-certificates \
        curl

# Install spatial libraries
RUN add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable && apt-get -qq update

RUN apt-get install --fix-missing -y --force-yes --no-install-recommends \
	netcdf-bin \
	libnetcdf-dev \
	ncview \
	libproj-dev \
	libgeos-dev \
	gdal-bin \
	libgdal-dev

# Python stuff from root
RUN pip install --upgrade pip
RUN pip install virtualenv
RUN pip install virtualenvwrapper
RUN pip3 install virtualenv
RUN pip3 install virtualenvwrapper

# Create user and add it to sudoers
RUN useradd --home /home/madmex_user --create-home --group sudo --shell /bin/bash madmex_user && \
	echo 'madmex_user:qwerty' | chpasswd
# database stuff
RUN apt-get install --fix-missing -y --force-yes --no-install-recommends \
	postgresql-9.5 \
	postgresql-contrib \
	postgresql-common \
	postgresql-client-9.5 \
	postgresql-client-common 

RUN service postgresql restart


# USER postgres
# RUN psql --command "CREATE USER madmex_user WITH SUPERUSER PASSWORD 'qwerty';"
# RUN createuser -s madmex_user
# 
# USER root

# Properly mount LUSTRE
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

COPY conf/entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# DB remap
VOLUME ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Work from useraccount madmex_user
USER madmex_user

RUN mkdir /home/madmex_user/git && mkdir /home/madmex_user/sandbox
RUN echo 'source /usr/local/bin/virtualenvwrapper.sh' >> /home/madmex_user/.bashrc
RUN echo "alias python=python3" >> /home/madmex_user/.bashrc

RUN cd /home/madmex_user/git && git clone https://github.com/CONABIO/antares3.git && cd antares3 && git checkout -b develop origin/develop
# RUN /bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh && alias python=python3 && mkvirtualenv antares"
# RUN pip install numpy && pip install cloudpickle && pip install GDAL==$(gdal-config --version) --global-option=build_ext --global-option="-I/usr/include/gdal"
# RUN pip install git+https://github.com/CONABIO/datacube-core.git@release-1.5
# RUN pip install -e .

COPY conf/.datacube.conf /home/madmex_user/.datacube.conf
COPY conf/.env /home/madmex_user/antares3/madmex/.env


