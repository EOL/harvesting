class Harvest::Fetcher
  def self.fetch_format_files(harvest)
    self.new(harvest).fetch
  end

  def initialize(harvest)
    @harvest = harvest
  end

  def fetch
    @harvest.formats.each do |fmt|
      # If it's in an archive
        # TODO: we need to allow archives on resources
        # Create a public archive dir, if it doesn't exist
        # Unless the archive dir already has contents that are newer than the harvest start time
          # If it's a URL, Fetch it into tmp dir
          # Unpack it (either in situ or in tmp dir) into the public archive dir
        # Throw an error if we don't find our file in the archive dir
        # Copy our file to where it belongs in public
      # If it's a file location
        # If it's already where it belongs in public
          # Log a warning (info, really) the the file was already in place
        # Otherwise
          # Copy it to public
      # Otherwise, if it's a URL,
        # Fetch the file into a tmp dir
          # Unzip it, if it's a zip
          # Untar it, if its a tarball
          # Un-tgz it, if it's a tgz
          #
          # Move it to where it belongs in public
          # Delete the tmp dir
      # Otherwise, throw an error (we don't know where to find this)
      # Update the record to point to the new loc, e.g.
      fmt.update_attribute(:file, fmt.get_from)
    end
  end
end
