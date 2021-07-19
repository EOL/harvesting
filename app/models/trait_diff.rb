class TraitDiff
  def initialize(resource, since)
    @resource = resource
    @since = since
  end

  def trait_adds
  end

  def trait_deletes
  end

  def metadata_adds
  end

  # don't need metadata_deletes_since because clients should delete metadata along with traits
  
  private
end
