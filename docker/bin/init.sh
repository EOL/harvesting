#!/bin/sh -e
APP="harvester"

echo "Updating $APP.."
cd /u/apps/$APP && git pull

/bin/bash -l -c 'gem install bundler --pre'
/bin/bash -l -c 'cd /u/apps/harvester/ && bundle'
/bin/bash -l -c 'service nginx start'
/bin/bash -l -c 'unicorn -c /u/apps/harvester/config/unicorn.rb -E staging -D'
