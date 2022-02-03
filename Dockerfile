FROM ruby:2.6.8-bullseye
MAINTAINER Jeremy Rice <jrice@eol.org>
LABEL Description="EOL Harvester"

ENV LAST_FULL_REBUILD 2021-11-03

# Install packages (note we update / clean up at the end of EACH run, because each gets an image)
RUN apt-get update -q && \
    apt-get install -qq -y build-essential libpq-dev curl wget \
    apache2-utils nodejs procps supervisor vim nginx \
    libmagickwand-dev imagemagick zip unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -q && \
    apt-get install -qq -y yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

ENV LAST_SOURCE_REBUILD 2018-08-20

COPY . /app
COPY config/nginx-sites.conf /etc/nginx/sites-enabled/default
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/imagemagick_policy.xml /etc/ImageMagick-6/policy.xml
# NOTE: supervisorctl and supervisord *service* doesn't work with custom config files, so just use default:
COPY config/supervisord.conf /etc/supervisord.conf
COPY Gemfile ./

RUN gem install bundler:2.1.4

RUN bundle config set without 'test development staging'
RUN bundle install --jobs 10 --retry 5

RUN touch /tmp/supervisor.sock
RUN chmod 777 /tmp/supervisor.sock
RUN ln -s /tmp /app/tmp

EXPOSE 3000

ENTRYPOINT ["/bin/bash", "-c", "source /app/docker/.env && rake assets:precompile && rm -f /tmp/*.pid /tmp/*.sock && /usr/bin/supervisord"]

CMD ["-c", "/etc/supervisord.conf"]
