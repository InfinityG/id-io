FROM ubuntu:14.04
MAINTAINER Infinity-G <developer@infinity-g.com>

#### General ####

RUN apt-get update && apt-get install -y curl wget git

#### Install Ruby, Bundler ####

RUN \
  apt-get update && \
  apt-get install -y ruby ruby-dev ruby-bundler && \
  rm -rf /var/lib/apt/lists/*
RUN gem install bundler

#### Clone Github repos ####

RUN mkdir -p home
RUN git clone https://github.com/InfinityG/id-io.git /home/id-io
RUN \
  cd /home/id-io && \
  bundler install --without test development

#### Set up MongoDB ####

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/10gen.list
RUN apt-get update && apt-get install -y mongodb-org
RUN mkdir -p /data/db

####

WORKDIR /home/id-io

EXPOSE 9002

CMD mongod --fork --logpath /var/log/mongodb.log && rackup -E test


# To build: sudo docker build -t infinityg/id-io:v1 .

# To run (TEST): sudo docker run -e API_AUTH_TOKEN=********* -e API_SECRET_KEY=********* -e API_PUBLIC_KEY=********* -e MONGO_DB=id-io -e MONGO_REPLICATED=false -e MONGO_HOST_1=localhost:27017 -e SMS_API_AUTH_TOKEN=********* -p 9002:9002 -it --rm infinityg/id-io:v1
# To run (PRODUCTION): sudo docker run -e API_AUTH_TOKEN=********* -e API_SECRET_KEY=********* -e API_PUBLIC_KEY=********* -e MONGO_DB=id-io -e MONGO_REPLICATED=true -e MONGO_HOST_1=10.0.1.10:27017 -e MONGO_HOST_2=10.0.1.11:27017 -e MONGO_HOST_3=10.0.1.12:27017 -e SMS_API_AUTH_TOKEN=********* -p 9002:9002 -it --rm infinityg/id-io:v1

# Inspect: sudo docker inspect [container_id]
# Delete all containers: sudo docker rm $(docker ps -a -q)
# Delete all images: sudo docker rmi $(docker images -q)
# Connect to running container: sudo docker exec -it [container_id] bash
# Attach to running container: sudo docker attach [container_id]
# Detach from running container without stopping process: Ctrl-p Ctrl-q
# Restart Docker service: sudo service docker.io restart