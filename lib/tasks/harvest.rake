namespace :harvest do
  task last: :environment do
    Resource.last.harvest
  end

  task undo: :environment do
    harvest = Harvest.last
    raise 'ABORTING: Harvest is more than 24 hours old; do it manually.' if harvest.created_at < 1.day.ago
    harvest.destroy
  end
end

desc 'Harvest the resource identified by ENV var: ID or ABBR.'
task harvest: :environment do
  resource = ENV['ID'] ? Resource.find(ENV['ID']) : Resource.find_by_abbr(ENV['ABBR'])
  resource.harvest
end
