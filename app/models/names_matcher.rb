class NamesMatcher
  def self.for_resource(resource)
    new(resource).start
  end

  def initialize(resource)
    @resource = resource
  end

  def start

  end
end
