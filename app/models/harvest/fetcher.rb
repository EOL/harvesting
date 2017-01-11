class Harvest::Fetcher
  def self.fetch_format_files(harvest)
    self.new(harvest).fetch
  end

  def initialize(harvest)
    @harvest = harvest
  end

  def fetch
    @harvest.formats.each do |fmt|
      # TODO ... I don't care right now. :)
      fmt.update_attribute(:file, fmt.get_from)
    end
  end
end
