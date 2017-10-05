# harvester
Service for harvesting resources from partners into a normalized database (for later publication)

## Be Sure Everything Is Running
rake db:reset ; rails runner "ResourceHarvester.new(Resource.first).start ; ResourceHarvester.new(Resource.where(name: 'Mineralogy').first).start ; ResourceHarvester.new(Resource.where(abbr: 'CalPhotos').first).start"

## Background services
bin/delayed_job run
