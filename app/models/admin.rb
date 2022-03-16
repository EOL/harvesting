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

    def verify_connection
      @@last_try ||= Time.now
      unless @@last_try <= 2.minutes.ago
        ActiveRecord::Base.connection.verify!
        @@last_try = Time.now
      end
    end

    def maintain_db_connection(process = nil)
      verify_connection
      tries = 0
      while tries <= 3 and !ActiveRecord::Base.connected?
        ActiveRecord::Base.connection.reconnect!
        tries += 1
        msg = if tries < 1
          'WARNING: lost connection to DB, reconnecting...'
        else
          "WARNING: DB still not responding, re-trying connection (attempt #{tries})..."
        end
      end
      process ? process.info(msgs.join("; ")) : Rails.logger.warn(msg) unless msgs.empty?
    end

    def retry_if_connection_fails(&block)
      verify_connection
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
