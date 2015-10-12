FROM ubuntu:14.04
MAINTAINER Infinity-G <developer@infinity-g.com>

#### General ####

RUN apt-get update && apt-get install -y curl git software-properties-common python-software-properties

#### Install NodeJS, NPM ####

RUN add-apt-repository -y ppa:chris-lea/node.js && \
    apt-get -y update

RUN apt-get install -y nodejs

#### Clone Github repo and install via NPM ####

RUN mkdir -p home
RUN git clone https://github.com/ripple/ripple-rest.git /home/ripple-rest
WORKDIR /home/ripple-rest
RUN npm install

#### Set up config ####

ADD ./config.json /home/ripple-rest/config.json

EXPOSE 5990

#CMD npm start
CMD ["/bin/bash"]