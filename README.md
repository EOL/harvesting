# harvester
Service for harvesting resources from partners into a normalized database (for later publication)

# Required Installations

You need to have `mysql`, `imagemagick@6`, and `elasticsearch` installed and *running* for this codebase to work.

# First Time

```
rake db:drop ; rake db:create ; rake db:migrate ; rake db:seed
```
...Then run the "Be Sure Everything Is Running" command, without the `rake db:reset`.

## Be Sure Everything Is Running

Note that the `rake db:reset` is first, below, only if you want to re-run the following commands later. You don't need
it the first time.

```
rake db:reset ; rails runner "ResourceHarvester.new(Resource.first).start ; ResourceHarvester.new(Resource.where(name: 'Mineralogy').first).start ; ResourceHarvester.new(Resource.where(abbr: 'CalPhotos').first).start"
```

## Background services

`bin/delayed_job run`
