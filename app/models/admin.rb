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
        ActiveRecord::Base.connection.query('select 1 from resources where id = 1')
        false
      rescue
        true
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

        def connection_fails?
      begin
        connection.exec_query('SELECT id FROM ranks LIMIT 1')
        false
      rescue
        return true
      end
    end

    def check_connection
      return true if connected?
      puts "Disconnected, reconnecting."
      reconnect
      return true if connected?
      puts "STILL disconnected, will keep trying..."
      max_pause = 512.seconds
      pause = 1.seconds
      while pause <= max_pause && ! connected?
        puts "Waiting #{pause} seconds..."
        sleep(pause)
        pause *= 2
        reconnect
      end
    end
    
    def reconnect
      ActiveRecord::Base.connection.reconnect!
    end

    def connected?
      return false unless ActiveRecord::Base.connected?
      begin
        ActiveRecord::Base.connection.query('select 1 from resources where id = 1')
        true
      rescue
        false
      end
    end
  end
end
