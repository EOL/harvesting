class PluckData
  @structure = {
    
  }

  class << self
    # Keys should look like [123, 456, 789, :traits-567, 'media-987'] etc... If there is no class prefix (before a
    # hyphen), it will assume the class is "nodes". Note that integers, symbols, and strings are allowed.
    def build_data(keys, options)
      new(keys, options).build_data
    end
  end

  # Options allowed:
  # resource_id: Integer --> will "fake" this new resource id in the output files
  def initialize(keys, options = {})
    @resource = nil # I want this initialized, but we'll find it later.
    @options = {}
    @keys = { nodes: [] }
    keys.each { |key| add_key(key) }
  end

  def build_data
    get_resource_from_first_key
    add_data_up_tree
    build_tsv
    grab_harvesting_data
    build_resource_files
    zip_resource_files
    report_output
  end

  private

  def add_key(key)
    if key.is_a?(Integer) || key =~ /^\d$/
      @keys[:nodes] << key
    elsif key !~ /.-./
      raise "Un-parsable argument: `#{key}`: must be of a number or of the form `table_name-1234`."
    else
      (table_name, id) = key.to_s.split('-')
      table_name = table_name.to_sym
      @keys[table_name] ||= []
      @keys[table_name] << id
    end
  end

  def add_data_up_tree

    validate_trait_ids # raises error if there is anything is in the wrong resource or if missing.
  end

  def build_tsv
  end

  def grab_harvesting_data
  end

  def build_resource_files
  end

  def zip_resource_files
  end

  def report_output
  end
end
