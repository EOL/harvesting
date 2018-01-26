# For connecting to the website Database.
class WebDb < ActiveRecord::Base
  self.abstract_class = true
  cfg = YAML.load_file(File.join(Rails.root, 'config', 'database.yml'))[Rails.env.to_s]
  cfg['database'] = "eol_#{Rails.env}"
  establish_connection cfg

  # TODO: it would be nice to sanitize all of the SQL.... but we're assuming things are "safe" as we're only running it
  # internally with trusted data.

  class << self
    def columns(table)
      response = connection.exec_query("DESCRIBE #{table}")
      names = response.rows.map(&:first)
      names.map(&:to_sym)
    end

    def raw_create(table, hash)
      vals = "'" + hash.values.join("','") + "'"
      connection.exec_insert("INSERT INTO #{table} (#{hash.keys.join(', ')}) VALUES (#{vals})", 'SQL', vals)
      WebDb.connection.last_inserted_id(table)
    end

    # Ranks need to be updated as soon as they are inserted, argh...
    def raw_create_rank(name)
      vals = "'" + hash.values.join("','") + "'"
      connection.exec_insert("INSERT INTO ranks (name) VALUES (#{name})", 'SQL', name)
      id = WebDb.connection.last_inserted_id('ranks')
      connection.exec_update("UPDATE ranks SET treat_as = #{id} WHERE ID = #{id}", 'SQL', [id, id])
      id
    end

    def map_ids(table, field)
      response = connection.exec_query("SELECT id, #{field} FROM #{table}")
      map = {}
      response.rows.each do |row|
        map[row[1]] = row[0]
      end
      map
    end

    def remove_resource_data(table, resource_id)
      connection.execute("DELETE FROM #{table} WHERE resource_id = #{resource_id}")
    end

    def import_csv(file, table, cols = nil)
      q = ['LOAD DATA']
      q << 'LOCAL' unless Rails.env.development?
      q << "INFILE '#{file}'"
      q << 'REPLACE ' unless cols
      q << "INTO TABLE `#{table}`"
      q << "(#{cols.join(',')})" if cols
      begin
        connection.execute(q.join(' '))
      rescue => e
        puts e.message
        debugger
        1
      end
    end

    # TODO: IMPORTANT! Create the resource if it's not there. Ugh.
    def resource_id(resource)
      response = connection.exec_query("SELECT id FROM resources WHERE repository_id = #{resource.id}")
      response.rows[0][0]
    end
  end
end
