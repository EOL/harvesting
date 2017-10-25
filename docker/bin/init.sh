#!/bin/sh -e
APP="harvester"

echo "Updating $APP.."
cd /u/apps/$APP && git pull && git checkout GEMFILE.lock

/bin/bash -l -c 'cd /u/apps/harvester/ && bundle' 
/bin/bash -l -c 'cd /u/apps/harvester/ && rake log:clear && rails s -d -b 0.0.0.0' 
