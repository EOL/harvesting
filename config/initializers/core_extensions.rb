class ActiveRecord::Base
  class << self
    # I AM NOT A FAN OF SQL... but this is **way** more efficient than alternatives:
    def propagate_id(options = {})
      fk = options[:fk]
      set = options[:set]
      with_field = options[:with]
      (o_table, o_field) = options[:other].split('.')
      sql  = "UPDATE `#{table_name}` t JOIN `#{o_table}` o ON (t.`#{fk}` = o.`#{o_field}`"
      sql += " AND t.harvest_id = ? AND o.harvest_id = t.harvest_id" if options[:harvest_id]
      sql += ") SET t.`#{set}` = o.`#{with_field}`"
      clean_execute([sql, options[:harvest_id]])
    end

    def clean_execute(args)
      clean_sql = sanitize_sql(args)
      connection.execute(clean_sql)
    end
  end
end
