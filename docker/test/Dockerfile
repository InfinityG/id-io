FROM ubuntu:14.04
MAINTAINER Infinity-G <developer@infinity-g.com>

#### General ####
RUN apt-get update && apt-get install -y curl wget git git-core curl zlib1g-dev build-essential
RUN apt-get install -y libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3
RUN apt-get install -y libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties

#### Install Ruby 2.2.1, Bundler ####

# Install rbenv to install ruby
RUN git clone git://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN echo '# rbenv setup' > /etc/profile.d/rbenv.sh
RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh
RUN echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN chmod +x /etc/profile.d/rbenv.sh

# Install rbenv plugin: ruby-build
RUN mkdir /usr/local/rbenv/plugins
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

# Let's not copy gem package documentation
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc

ENV RBENV_ROOT /usr/local/rbenv
ENV PATH $RBENV_ROOT/bin:$RBENV_ROOT/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Install ruby
RUN rbenv install 2.1.2
RUN rbenv local 2.1.2
RUN rbenv global 2.1.2

# Install Bundler
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


################################################################################
# Build and run instructions
################################################################################

# BUILD IMAGE:
# sudo docker build -t infinityg/id-io:v1 .

# RUN CONTAINER:
# sudo docker run -e API_AUTH_TOKEN=* -e API_SECRET_KEY=* -e API_PUBLIC_KEY=* -e MONGO_DB=id-io -e MONGO_REPLICATED=false -e MONGO_HOST_1=localhost:27017 -e SMS_API_AUTH_TOKEN=* -p 9002:9002 -it --rm infinityg/id-io:v1

# OTHER USEFUL COMMANDS:
# - Inspect: sudo docker inspect [container_id]
# - Delete all containers: sudo docker rm $(docker ps -a -q)
# - Delete all images: sudo docker rmi $(docker images -q)
# - Connect to running container: sudo docker exec -it [container_id] bash
# - Attach to running container: sudo docker attach [container_id]
# - Detach from running container without stopping process: Ctrl-p Ctrl-q
# - Restart Docker service: sudo service docker.io restart