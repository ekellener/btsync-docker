FROM ubuntu:14.04
MAINTAINER Adrien Duermael (adrien@duermael.com)

ENV DEBIAN_FRONTEND noninteractive

########## BTSYNC ##########

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get install curl -y
RUN apt-get install nodejs -y


RUN curl -o /usr/bin/btsync.tar.gz  https://download-cdn.resilio.com/stable/linux-x64/resilio-sync_x64.tar.gz
# More current verison
#RUN curl -o /usr/bin/btsync.tar.gz http://download-new.utorrent.com/endpoint/btsync/os/linux-x64/track/stable 
RUN cd /usr/bin; tar xvzf btsync.tar.gz; rm btsync.tar.gz;
RUN ln -s /usr/bin/rslsync /usr/bin/btsync
ADD btsync /btsync
RUN mkdir /btsync/storage

EXPOSE 55555

WORKDIR /btsync

# Arguments: DIR SECRET
ENTRYPOINT ["/bin/bash", "./start.sh"]
