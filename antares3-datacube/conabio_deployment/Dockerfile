FROM ubuntu:xenial
MAINTAINER Erick Palacios-Moreno

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# install basic packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && echo "America/Mexico_City" > /etc/timezone && apt-get install -y tzdata locales\
	openssh-server \
	openssl \
	sudo \
	wget \
	nano \
	software-properties-common \
	git \
	vim \
	vim-gtk \
	htop \
	build-essential \
	libssl-dev \
	libffi-dev \
	python3-dev \
	cmake \
	python3-pip \
	python3-setuptools \
        python-gdal \
	ca-certificates \
	curl \
   	tmux \
        postgresql-client \
        libudunits2-dev \
        nodejs && pip3 install --upgrade pip

# Install spatial libraries
RUN add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable && apt-get -qq update

RUN apt-get install -y \
	netcdf-bin \
	libnetcdf-dev \
	ncview \
	libproj-dev \
	libgeos-dev \
	gdal-bin \
	libgdal-dev

# Python stuff from root
RUN pip3 install virtualenv virtualenvwrapper

# Properly mount LUSTRE
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu


COPY conf/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
