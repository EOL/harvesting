namespace :publish do
  task last: :environment do
    Resource.last.publish
  end
end

desc 'Build the TSV for the resource identified by ENV var: ID or ABBR.'
task publish: :environment do
  resource = ENV['ID'] ? Resource.find(ENV['ID']) : Resource.find_by_abbr(ENV['ABBR'])
  resource.publish
end
