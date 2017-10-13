namespace :reset do
  desc 'reset the database ENTIRELY. Your gun, your foot: use caution.'
  task full: :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
  end

  task full_with_harvest: :full do
    ResourceHarvester.new(Resource.first).start
  end

  task first_harvest: :environment do
    Rake::Task['db:reset'].invoke
    ResourceHarvester.new(Resource.first).start
  end

  task full_with_all_harvests: :full_with_harvest do
    ResourceHarvester.new(Resource.where(name: 'Mineralogy').first).start
    ResourceHarvester.new(Resource.where(abbr: 'CalPhotos').first).start
  end

  task all_harvests: :environment do
    Rake::Task['db:reset'].invoke
    ResourceHarvester.new(Resource.first).start
    ResourceHarvester.new(Resource.where(name: 'Mineralogy').first).start
    ResourceHarvester.new(Resource.where(abbr: 'CalPhotos').first).start
  end
end
