FROM encoflife/base.ruby:0.2.4
MAINTAINER Martin Taheri <m3hran@gmail.com>
LABEL Description="EOL repo harvester image"
ENV TERM xterm
ENV TZ America/New_York

# Install packages
RUN clean_install.sh --no-install-recommends \
    g++ libmysqlclient-dev default-jre libmagickwand-dev imagemagick

RUN cd /u/apps/ && git clone https://github.com/EOL/harvester.git
RUN cd /u/apps/harvester && git pull

# Install gnparser
RUN mkdir -p /u/tmp
RUN cd /u/tmp && wget https://github.com/GlobalNamesArchitecture/gnparser/releases/download/release-0.4.2/gnparser-0.4.2.zip \
    && unzip gnparser-0.4.2.zip && mv gnparser-0.4.2 /u/apps/gnparser && rm -f /usr/local/bin/gnparser \
    && ln -s /u/apps/gnparser/bin/gnparser /usr/local/bin && rm -rf /u/tmp

# Configuration
RUN /bin/bash -l -c 'cd /u/apps/harvester/ && bundle'
ADD bin/init.sh /etc/my_init.d/

# Cleanup
RUN rm -rf /tmp/* /var/tmp/* /usr/local/src/*

EXPOSE 3000
WORKDIR /u/apps/harvester
