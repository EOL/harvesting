namespace :harvest do
  task last: :environment do
    Resource.last.rm_lockfile if ENV['FORCE']
    Resource.last.harvest
  end

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
end

desc 'Harvest the resource identified by ENV var: ID or ABBR.'
task harvest: :environment do
  resource = ENV['ID'] ? Resource.find(ENV['ID']) : Resource.find_by_abbr(ENV['ABBR'])
  resource.rm_lockfile if ENV['FORCE']
  resource.harvest
end
