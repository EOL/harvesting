# A place to stick some code useful for administration, but not really related to the code per-se.
class Admin
  @@last_try = Time.now
  class << self
    def optimize_tables
      ApplicationRecord.descendants.each do |klass|
        puts "++ #{klass}"
        klass.connection.execute("OPTIMIZE TABLE `#{klass.table_name}`")
      end
    end

    def maintain_db_connection(process = nil)
      tries = 0
      max_tries = 3
      msgs = []
      while tries <= max_tries && connection_fails?
        ActiveRecord::Base.connection.reconnect!
        tries += 1
        msgs << if tries > max_tries
          raise "Unable to reconnect to database! Exiting."
        elsif tries < 1
          'WARNING: lost connection to DB, reconnecting...'
        else
          "WARNING: DB still not responding, re-trying connection (attempt #{tries})..."
        end
      end
      unless msgs.empty?
        Rails.logger.warn(msgs.join("\n"))
        puts msgs.join("\n")
        process.info(msgs.join("; ")) if process
      end
    end

    def connection_fails?
      begin
        Resource.exists?(id: 1)
        false
      rescue
        return true
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
