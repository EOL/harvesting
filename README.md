# harvester
Service for harvesting resources from partners into a normalized database (for later publication)

# Environment:
set ELASTICSEARCH_URL
set the ENV variables from database.yml.

# Required Installations

You need to have `mysql`, `imagemagick@6`, and `elasticsearch` installed and *running* for this codebase to work.

# First Time

```
rake reset:full_with_all_harvests
```

## Resetting

If the migrations haven't changed, you can save a second or two and run:

```
rake reset:all_harvests
```

## Background services

`bin/delayed_job run`

## NOTES:

- The logs can get quite large over time. It is recommended you set up logrotate
  on the host / hypervisor to clean out `log/*log`. There is a file in the
  `config` folder called `logrotate.conf.template` which you can customize.
