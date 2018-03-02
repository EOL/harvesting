desc 'List resources!'
task resources: :environment do
  last_harvest_id = Harvest.last.id
  Resource.all.includes(:harvests).each do |resource|
    printf('% 3d: %s (%s)', resource.id, resource.name, resource.abbr)
    print "\n"
    resource.harvests.each do |harvest|
      printf('     Harvest#%d (%s):', harvest.id, harvest.stage)
      print '    <-------------- LAST HARVEST' if last_harvest_id == harvest.id
      print "\n"
      print "       #{harvest.nodes.count} Nodes, #{harvest.media.count} Media, #{harvest.traits.count} Traits,"
      print " #{harvest.assocs.count} Assocs,"
      puts " #{harvest.articles.count} Articles, #{harvest.vernaculars.count} Vernaculars"
    end
  end
end
