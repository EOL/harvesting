# A place to stick some code useful for administration, but not really related to the code per-se.
class Admin
  class << self
    def optimize_tables
      %w[vernaculars traits traits_references scientific_names resources references occurrences
         occurrence_metadata nodes_references nodes node_ancestors media media_references locations
         identifiers harvests formats fields content_attributions bibliographic_citations
         attributions assocs_references assocs assoc_traits articles].each do |table|
           Node.connection.execute("OPTIMIZE TABLE `#{table}`")
         end
    end

    def maintain_db_connection(process = nil)
      tries = 0
      while tries <= 3 and !ActiveRecord::Base.connected?
        ActiveRecord::Base.connection.reconnect!
        tries += 1
        msg = if tries < 1
          'WARNING: lost connection to DB, reconnecting...'
        else
          "WARNING: DB still not responding, re-trying connection (attempt #{tries})..."
        end
        process ? process.info(msg) : Rails.logger.warn(msg)
      end
    end

    def retry_if_connection_fails(&block)
      tried = false
      begin
        yield
      rescue => e
        raise e if tried
        tried = true
        ActiveRecord::Base.connection.reconnect!
        WebDb.connection.reconnect!
        retry
      end
    end
  end
end
