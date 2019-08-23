FROM ubuntu:bionic

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && echo "America/Mexico_City" > /etc/timezone && apt-get install -y tzdata

RUN apt-get update && apt-get install -y wget curl && wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v$(curl -s https://api.github.com/repos/Yelp/dumb-init/releases/latest| grep tag_name|sed -n 's/  ".*v\(.*\)",/\1/p')/dumb-init_$(curl -s https://api.github.com/repos/Yelp/dumb-init/releases/latest| grep tag_name|sed -n 's/  ".*v\(.*\)",/\1/p')_amd64 && chmod +x /usr/local/bin/dumb-init

RUN apt-get update && apt-get install -y \
            sudo \
            nano \
            openssh-server \
            openssl \
            gpg-agent \
            curl


# Add VOLUMEs to allow backup of config, logs and databases
VOLUME ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]
COPY conf/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
