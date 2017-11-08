desc 'Harvest the resource identified by ENV var: ID or ABBR.'
task harvest: :environment do
  resource = ENV['ID'] ? Resource.find(ENV['ID']) : Resource.find_by_abbr(ENV['ABBR'])
  ResourceHarvester.new(resource).start
end
