desc 'Analyze the fields in the DB to better handle new resources.'
namespace :meta_config do
  task analyze: :environment do
    MetaConfig.analyze
  end
end
