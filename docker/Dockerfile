FROM encoflife/base.ruby
MAINTAINER Martin Taheri <m3hran@gmail.com>
LABEL Description="EOL repo harvester image"
ENV TERM xterm
ENV TZ America/New_York

# Install packages
RUN clean_install.sh --no-install-recommends \
    g++ libmysqlclient-dev default-jre

RUN cd /u/apps/ && git clone https://github.com/EOL/harvester.git

# Configuration 
RUN /bin/bash -l -c 'cd /u/apps/harvester/ && bundle' 
ADD bin/init.sh /etc/my_init.d/


# Cleanup
RUN rm -rf /tmp/* /var/tmp/* /usr/local/src/*

EXPOSE 3000
WORKDIR /u/apps
