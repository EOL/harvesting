namespace :meta_config do
  desc 'Analyze the fields in the DB to better handle new resources.'
  task analyze: :environment do
    MetaConfig.analyze
  end
end
