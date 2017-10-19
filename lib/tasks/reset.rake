# @all = %w[Mineralogy CalPhotos flickrBHL IUCN-SD]
@all = %w[IUCN-SD]

namespace :reset do
  namespace :full do
    desc 'rebuild the database, re-running migrations. Your gun, your foot: use caution. No harvests are performed.'
    task empty: :environment do
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['db:seed'].invoke
    end

    desc 'rebuild the database, re-running migrations. Only the DWH harvest is performed.'
    task first: :empty do
      ResourceHarvester.new(Resource.first).start
    end

    desc 'rebuild the database, re-running migrations. All seed harvests are performed.'
    task all: :first do
      @all.each { |abbr| ResourceHarvester.new(Resource.where(abbr: abbr).first).start }
    end
  end

  desc 'reset the database, using the schema instead of migrations. Only the DWH harvest is performed.'
  task first: :environment do
    Rake::Task['db:reset'].invoke
    ResourceHarvester.new(Resource.first).start
  end

  desc 'reset the database, using the schema instead of migrations. All seed harvests are performed.'
  task all: :first do
    @all.each { |abbr| ResourceHarvester.new(Resource.where(abbr: abbr).first).start }
  end
end
