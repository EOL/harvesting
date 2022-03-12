# A place to stick some code useful for administration, but not really related to the code per-se.
class Admin
  @@last_try = Time.now
  class << self
    def optimize_tables
      %w[vernaculars traits traits_references scientific_names resources references occurrences
         occurrence_metadata nodes_references nodes node_ancestors media media_references locations
         identifiers harvests formats fields content_attributions bibliographic_citations
         attributions assocs_references assocs assoc_traits articles harvest_processes].each do |table|
           Node.connection.execute("OPTIMIZE TABLE `#{table}`")
         end
    end

    def maintain_db_connection(process = nil)
      @@last_try ||= Time.now
      ActiveRecord::Base.connection.verify! unless @@last_try <= 2.minutes.ago
      tries = 0
      msgs = []
      while tries <= 3 and !ActiveRecord::Base.connected?
        ActiveRecord::Base.connection.reconnect!
        tries += 1
        msgs << if tries < 1
          'WARNING: lost connection to DB, reconnecting...'
        else
          "WARNING: DB still not responding, re-trying connection (attempt #{tries})..."
        end
      end
      process ? process.info(msgs.join("; ")) : Rails.logger.warn(msg) unless msgs.empty?
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
