@all = %w[Mineralogy CalPhotos flickrBHL IUCN-SD mam_inter carn_names] # MISSING FILE: carn_art]

namespace :reset do
  namespace :full do
    desc 'rebuild the database, re-running migrations. Your gun, your foot: use caution. No harvests are performed.'
    task none: :environment do
      Rake::Task['log:clear'].invoke
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['searchkick:reindex:all'].invoke
      Rake::Task['db:seed'].invoke
    end

    desc 'rebuild the database, re-running migrations. Only the DWH harvest is performed.'
    task first: :none do
      ResourceHarvester.new(Resource.native).start
    end

    desc 'rebuild the database, re-running migrations. The DWH harvests is performed, then the resource with the ENV RESOURCE abbreviation is run.'
    task only: :first do
      ResourceHarvester.by_abbr(ENV['RESOURCE'])
    end

    desc 'rebuild the database, re-running migrations. All seed harvests are performed.'
    task all: :first do
      @all.each { |abbr| ResourceHarvester.by_abbr(abbr) }
    end
  end

  desc 'reset the database, using the schema instead of migrations. Only the DWH harvest is performed.'
  task first: :environment do
    Rake::Task['log:clear'].invoke
    Rake::Task['db:reset'].invoke
    Rake::Task['searchkick:reindex:all'].invoke
    ResourceHarvester.new(Resource.native).start
  end

  desc 'reset the database, using the schema instead of migrations. All seed harvests are performed.'
  task only: :first do
    ResourceHarvester.by_abbr(ENV['RESOURCE'])
  end

  desc 'reset the database, using the schema instead of migrations. All seed harvests are performed.'
  task all: :first do
    @all.each { |abbr| ResourceHarvester.by_abbr(abbr) }
  end
end
