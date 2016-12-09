class Resource < ActiveRecord::Base
  has_many :formats, inverse_of: :resource
  has_many :harvests, inverse_of: :resource

  acts_as_list

  def create_harvest_instance
    harvest = Harvest.create(resource_id: id)
    harvests << harvest
    formats.each { |fmt| fmt.copy_to_harvest(harvest) }
    harvest
  end
end
