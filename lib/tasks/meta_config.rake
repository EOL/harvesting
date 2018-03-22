namespace :meta_config do
  desc 'Analyze the fields in the DB to better handle new resources.'
  task analyze: :environment do
    Resource::FromMetaXml.analyze
  end

  desc 'Read the anaylzed meta config JSON and import new entries (only) into the database.'
  task load: :environment do
    MetaXmlField.load
  end
end
