class UrisAreEolTerms
  def initialize(klass)
    @klass = klass
  end

  def uri(method)
    return nil if @klass.nil? # Sometimes we ask for a non-existent occurrence!
    return nil unless @klass.respond_to?(method)

    uri = @klass.send(method)
    return nil if uri.blank?

    term = EolTerms.by_uri(uri)
    return nil unless term.is_a?(Hash)

    term['uri']
  end
end
