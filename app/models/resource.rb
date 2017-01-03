class Resource < ActiveRecord::Base
  has_many :formats, inverse_of: :resource
  has_many :harvests, inverse_of: :resource
  has_many :scientific_names, inverse_of: :resource
  has_many :nodes, inverse_of: :resource
  has_many :vernaculars, inverse_of: :resource
  has_many :media, inverse_of: :resource

  acts_as_list

  def self.quick_define(options)
    next_pos = maximum(:position) + 1
    resource = where(name: options[:name]).first_or_create do |r|
      abbr = options[:name].gsub(/[^A-Z]/, "")
      abbr ||= options[:name][0..3].upcase
      r.site_id = options[:site_id]
      r.site_pk = abbr
      r.position = next_pos
      r.name = options[:name]
      r.abbr = abbr
    end
    pos = 1
    options[:formats].each do |rep, f_def|
      fmt = Format.where(
            resource_id: resource.id,
            represents: rep).
          abstract.
          first_or_create do |f|
        f.resource_id = resource.id
        f.represents = rep
        f.position = pos
        f.file_type = Format.file_types[options[:type]]
        f.get_from = "#{options[:base_dir]}/#{f_def[:loc]}"
      end
      pos += 1
      field_pos = 1
      f_def[:fields].each do |field|
        Field.where(format_id: fmt.id, position: field_pos).first_or_create do |f|
          f.format_id = fmt.id
          f.position = field_pos
          f.expected_header = field.keys.first
          f.mapping = field.values.first
          f.submapping = field[:submapping]
          f.unique_in_format = field[:is_unique] || false
          f.can_be_empty = field.has_key?(:can_be_empty) ? field[:can_be_empty] : true
        end
        field_pos += 1
      end
    end
    resource
  end

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