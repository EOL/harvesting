class ActiveRecord::Base
  class << self
    # I AM NOT A FAN OF SQL... but this is **way** more efficient than alternatives:
    def propagate_id(options = {})
      min = nil
      max = nil
      if options[:harvest_id]
        min = where(harvest_id: options[:harvest_id]).minimum(:id)
        if min.nil?
          debugger if where(harvest_id: options[:harvest_id]).count.positive?
          # If there's more than zero rows, min should not be nil. If there were zero rows, nothing to do:
          return
        end
        max = where(harvest_id: options[:harvest_id]).maximum(:id)
      else
        min = minimum(:id)
        max = maximum(:id)
      end
      fk = options[:fk]
      set = options[:set]
      with_field = options[:with]
      (o_table, o_field) = options[:other].split('.')
      update_clause  = "UPDATE `#{table_name}` t JOIN `#{o_table}` o ON (t.`#{fk}` = o.`#{o_field}`"
      update_clause += ' AND t.harvest_id = ? AND o.harvest_id = t.harvest_id' if options[:harvest_id]
      update_clause += ')'
      set_clause = "SET t.`#{set}` = o.`#{with_field}`"
      page_size = 10_000
      if max - min > page_size
        range_clause = "WHERE t.#{primary_key} >= ? AND t.#{primary_key} <= ?"
        while max > min
          upper = min + page_size - 1
          if options[:harvest_id]
            clean_execute([[update_clause, set_clause, range_clause].join(' '), options[:harvest_id], min, upper])
          else
            clean_execute([[update_clause, set_clause, range_clause].join(' '), min, upper])
          end
          min += page_size
        end
      else
        clean_execute([[update_clause, set_clause].join(' '), options[:harvest_id]])
      end
    end

    def clean_execute(args)
      clean_sql = sanitize_sql(args)
      connection.execute(clean_sql)
    end
  end
end
