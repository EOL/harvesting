# For connecting to the website Database. NOTE: This code is not especially concerned about SQL-injection, as the data
# are all either from a trusted database or from a trusted resource file. NOTHING HERE COMES FROM USERS.
class WebDb < ApplicationRecord
  self.abstract_class = true
  cfg = ApplicationRecord.configurations[Rails.env]
  cfg['database'] = Rails.application.secrets.web_db[:database]
  cfg['username'] = Rails.application.secrets.web_db[:username]
  cfg['password'] = Rails.application.secrets.web_db[:password]
  cfg['host']     = Rails.application.secrets.web_db[:host]
  cfg['port']     = Rails.application.secrets.web_db[:port]
  establish_connection cfg
  @types = %w[referent node identifier scientific_name node_ancestor vernacular article medium image_info page_content
              reference attribution content_section bibliographic_citation]
  @page_columns_to_update =
    %w[id updated_at media_count articles_count links_count maps_count nodes_count
       vernaculars_count scientific_names_count referents_count native_node_id]
  @ranks = {}
  @licenses = {}
  @languages = {}
  @taxonomic_statuses = {}

  class << self
    attr_reader :page_columns_to_update, :types, :ranks, :licenses, :languages, :taxonomic_statuses

    def init
      build_structs
      build_ranks
      build_languages
      build_licenses
      build_taxonomic_statuses
      build_roles
    end

    def build_ranks
      @ranks = map_ids('ranks', 'name')
    end

    def build_languages
      @languages = map_ids('languages', 'code')
    end

    def build_licenses
      @licenses = map_ids('licenses', 'source_url')
    end

    def build_taxonomic_statuses
      @taxonomic_statuses = map_ids('taxonomic_statuses', 'name')
    end

    def build_roles
      @roles = map_ids('roles', 'name')
    end

    def rank(full_rank, process)
      return nil if full_rank.nil?
      rank = full_rank.downcase
      return nil if rank.blank?
      return @ranks[rank] if @ranks.key?(rank)
      process.warn("Encountered new rank, please ensure there are handlers for it: #{rank}")
      @ranks[rank] = raw_create_rank(rank) # NOTE this is NOT #raw_create, q.v..
    end

    def role(full_role, process)
      return nil if full_role.nil?
      role = full_role.downcase
      return nil if role.blank?
      return @roles[role] if @roles.key?(role)
      process.warn("Encountered new role, please ensure there is a translation for it: #{role}")
      @roles[role] = raw_create('roles', name: role, created_at: Time.now.to_s(:db), updated_at: Time.now.to_s(:db))
    end

    def license(url, process)
      return nil if url.nil?
      license = url.downcase
      return nil if license.blank?
      return @licenses[license] if @licenses.key?(license)
      process.warn("Encountered new license, please find a logo URL and give it a name: #{url}")
      # NOTE: passing int case-sensitive name... and a bogus name.
      @licenses[license] = raw_create('licenses', source_url: url, name: url, created_at: Time.now.to_s(:db),
                                                  updated_at: Time.now.to_s(:db))
    end

    def language(language, process)
      return nil if language.blank?
      return @languages[language.code] if @languages.key?(language.code)
      process.log("Encountered new language, please assign it to a Locale and give it a name: #{language.code}")
      @languages[language.code] = raw_create('languages', code: language.code)
    end

    def taxonomic_status(full_name, process)
      name = full_name&.downcase
      name = 'accepted' if name.blank? # Empty taxonomic_statuses are NOT allowed; this is the default assumption.
      return @taxonomic_statuses[name] if @taxonomic_statuses.key?(name)
      process.log('Encountered new taxonomic status, please assign set its '\
                      "alternative/preferred/problematic/mergeable: #{name}")
      @taxonomic_statuses[name] = raw_create('taxonomic_statuses', name: name)
    end

    def build_structs
      (@types + ['page']).each do |type|
        attributes = columns(type.pluralize)
        Struct.new("Web#{type.camelize}", *attributes)
      end
    end

    def now
      Time.now.to_s(:db)
    end

    def columns(table)
      response = exec_query("DESCRIBE `#{table}`")
      names = response.rows.map(&:first)
      names.map(&:to_sym)
    end

    def raw_create(table, hash)
      vals = hash.values.map { |val| quote_value(val) }
      connection.reconnect! unless connected? and connection.active?
      tried = false
      begin
        connection.exec_insert("INSERT INTO #{table} (`#{hash.keys.join('`, `')}`) VALUES (#{vals.join(',')})", 'SQL', vals)
      rescue => e
        raise "Exception of class #{e.class}, you should rescue those here."
        if tried
          raise e
        else
          tried = true
        end
      end
      connection.send(:last_inserted_id, table)
    end

    def update_resource(obj, logger = nil)
      web_id = resource_id(obj)
      logger = obj.process_log if logger.nil?
      lic = license(License.find(obj.dataset_license_id).source_url, logger) if obj.dataset_license_id
      hash = {
        name: obj.name,
        # url: # Ruh-roh, need to add this to HARV DB.
        description: obj.description,
        notes: obj.notes,
        is_browsable: obj.is_browsable,
        has_duplicate_nodes: obj.might_have_duplicate_taxa,
        node_source_url_template: obj.pk_url,
        dataset_license_id: lic,
        dataset_rights_holder: obj.dataset_rights_holder,
        dataset_rights_statement: obj.dataset_rights_statement,
        updated_at: obj.updated_at,
        abbr: obj.abbr,
        classification: obj.classification,
        native: obj.native
      }
      attrs = hash.map { |k, v| "#{k}=#{quote_value(v)}" }.join(', ')
      connection.exec_update("UPDATE resources SET #{attrs} WHERE id = #{web_id}", 'SQL', attrs)
      logger
    end

    def change_resource_id(old_id, new_id)
      connection.exec_update("UPDATE resources SET id = #{new_id} WHERE id = #{old_id}", 'SQL', [])
    end

    def quote_value(val)
      return 'NULL' if val.nil?
      return ApplicationRecord.connection.quote(val) if val.is_a?(ActiveSupport::TimeWithZone)
      return val if val.is_a?(Numeric)
      return 1 if val.is_a? TrueClass
      return 0 if val.is_a? FalseClass

      "'#{val.to_s.gsub(/'/, "''")}'"
    end

    # Ranks need to be updated as soon as they are inserted, argh...
    def raw_create_rank(name)
      id = raw_create('ranks', name: name)
      connection.exec_update("UPDATE ranks SET treat_as = #{id} WHERE ID = #{id}", 'SQL', [id, id])
      id
    end

    def map_ids(table, field, options = {})
      q = "SELECT id, #{field} FROM #{table}"
      q += " WHERE resource_id = #{options[:resource_id]}" if options[:resource_id]
      q += " ORDER BY id DESC LIMIT #{options[:limit]}" if options[:limit]
      response = exec_query(q)
      map = {}
      response.rows.each do |row|
        map[row[1]] = row[0]
      end
      map
    end

    def remove_resource_data(table, resource_id)
      connection.execute("DELETE FROM #{table} WHERE resource_id = #{resource_id}")
    end

    def create_temp_pages_table(id)
      table = "temp_pages_#{id}"
      connection.execute("CREATE TEMPORARY TABLE #{table} LIKE pages")
      table
    end

    def load_pages_from_temp(temp_table)
      updates = page_columns_to_update[1..-1].map { |col| "`#{col}` = VALUES(`#{col}`)" }
      q = ['INSERT INTO pages']
      q << "SELECT * FROM #{temp_table}"
      q << "ON DUPLICATE KEY UPDATE #{updates.join(', ')}"
      connection.execute(q.join(' '))
    end

    def drop_temp_pages_table(temp_table)
      connection.execute("DROP TEMPORARY TABLE #{temp_table}")
    end

    def resource_id(resource)
      id = find_by_repo_id(:resources, resource.id)
      return id unless id.nil?

      create_resource(resource)
    end

    def partner_id(partner)
      id = find_by_repo_id(:partners, partner.id)
      return id unless id.nil?

      create_partner(partner)
    end

    def create_resource(resource)
      common_fields = %i[nodes_count name abbr description notes is_browsable]
      create_from_object(resource, common_fields) do |hash|
        hash[:has_duplicate_nodes] = !resource.might_have_duplicate_taxa?
        hash[:partner_id] = partner_id(resource.partner)
        hash[:repository_id] = resource.id
      end
    end

    def create_partner(partner)
      common_fields = %i[name abbr short_name homepage_url description links_json]
      create_from_object(partner, common_fields) do |hash|
        hash[:repository_id] = partner.id
      end
    end

    def create_from_object(object, common_fields, &block)
      hash = {}
      common_fields.each do |field|
        hash[field] = object[field]
      end
      yield(hash) if block
      hash[:updated_at] = hash[:created_at] = now
      table = object.class.table_name
      raw_create(table, hash)
      connection.send(:last_inserted_id, table)
    end

    def find_by_repo_id(table, id)
      rows = exec_query("SELECT id FROM `#{table}` WHERE repository_id = #{id} LIMIT 1").rows
      rows.empty? ? nil : rows[0][0]
    end

    def any_nodes?(id)
      rows = exec_query("SELECT id FROM nodes WHERE resource_id = #{id} LIMIT 1").rows
      rows.empty? ? nil : rows[0][0]
    end

    def pages_to_update(page_ids)
      all_pages = []
      page_ids.in_groups_of(5_000, false) do |group|
        all_pages += existing_pages(page_ids)
      end
      all_pages.compact
    end

    def existing_pages(page_ids)
      exec_query("SELECT * FROM pages WHERE id IN (#{page_ids.compact.join(',')})").rows
    end

    def exec_query(query)
      connection.reconnect! unless connected?
      connection.exec_query(query)
    end
  end
end
