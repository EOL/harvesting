class Resource < ActiveRecord::Base
  has_many :formats, inverse_of: :resource
  has_many :harvests, inverse_of: :resource
  has_many :scientific_names, inverse_of: :resource
  has_many :nodes, inverse_of: :resource

  acts_as_list

  def create_harvest_instance
    harvest = Harvest.create(resource_id: id)
    harvests << harvest
    formats.abstract.each { |fmt| fmt.copy_to_harvest(harvest) }
    harvest
  end

  def start_harvest
    harvester = ResourceHarvester.new(self)
    harvester.start
    harvester
  end
end
