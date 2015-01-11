# Dockerfile for a standard uproxy-lib instance

FROM selenium/node-chrome
MAINTAINER Lalon Aziz <klazizpro@gmail.com>

USER root

RUN apt-get update -qqy \
  && apt-get -qqy install \
    nodejs nodejs-legacy git npm 

RUN npm install -g grunt-cli
ADD . /uproxy-lib
WORKDIR /uproxy-lib

RUN npm install

ENV DISPLAY :10

ENTRYPOINT ["/uproxy-lib/tools/docker-entrypoint.sh"]
