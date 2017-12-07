desc 'Grab resource files from the drop dir.'
task drop: :environment do
  DropDir.check
end
