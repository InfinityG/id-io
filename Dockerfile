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
RUN git clone git@github.com:InfinityG/id-io.git /home/id-io
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