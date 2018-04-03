namespace :harvest do
  desc 'Harvest the last resource (by ID)'
  task last: :environment do
    Resource.last.rm_lockfile if ENV['FORCE']
    Resource.last.harvest
  end

  desc 'Harvest an OpenData URL (you must put the URL in an environment variable called ... uhhh... URL, and use quotes.)'
  task opendata: :environment do
    Resource::FromOpenData.url(ENV['URL']).harvest
  end

  desc 'Undo the last harvest, removing all of its content (leaving the resource)'
  task undo: :environment do
    harvest = Harvest.last
    resource = harvest.resource
    identifier = "Harvest##{harvest.id} for #{resource.name} (##{resource.id} #{resource.abbr})"
    raise "ABORTING: #{identifier} is more than 24 hours old, are you sure? FORCE=1 if so." if
      harvest.created_at < 1.day.ago && !ENV.key?('FORCE')
    puts "About to destroy #{identifier}..."
    puts 'YOU HAVE THREE SECONDS TO CANCEL...'
    sleep(3)
    harvest.destroy
  end

  desc 'Re-Harvest the resource identified by ENV var: ID or ABBR. (Destroys old harvests)'
  task redo: :environment do
    resource = ENV['ID'] ? Resource.find(ENV['ID']) : Resource.find_by_abbr(ENV['ABBR'])
    resource ||= Harvest.last.resource # No info given, so assume the last one we did!
    resource.rm_lockfile if ENV['FORCE']
    resource.re_harvest
  end

  desc 'Resume Harvest of resource identified by ENV var: ID or ABBR. Non-destructive.'
  task resume: :environment do
    resource = ENV['ID'] ? Resource.find(ENV['ID']) : Resource.find_by_abbr(ENV['ABBR'])
    resource ||= Harvest.last.resource # No info given, so assume the last one we did!
    resource.rm_lockfile if ENV['FORCE']
    resource.resume
  end
end

desc 'Harvest the resource identified by ENV var: ID or ABBR.'
task harvest: :environment do
  resource = ENV['ID'] ? Resource.find(ENV['ID']) : Resource.find_by_abbr(ENV['ABBR'])
  resource.rm_lockfile if ENV['FORCE']
  resource.harvest
end
