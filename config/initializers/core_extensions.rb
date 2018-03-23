class ActiveRecord::Base
  class << self
    # I AM NOT A FAN OF SQL... but this is **way** more efficient than alternatives:
    def propagate_id(options = {})
      filter = options[:harvest_id] || options[:resource_id]
      filter_field =
        if filter
          # Harvest is more specific, prefer it:
          options[:harvest_id] ? :harvest_id : :resource_id
        end
      size_query = where('1=1')
      size_query = size_query.where(filter_field => filter) if filter
      size_query = size_query.where(options[:poly_type] => options[:poly_val]) if options[:poly_type]
      min = size_query.minimum(:id)
      if min.nil?
        # If there's more than zero rows, min should not be nil. If there were zero rows, nothing to do:
        return if size_query.count.zero?
      end
      max = size_query.maximum(:id)
      fk = options[:fk]
      set = options[:set]
      with_field = options[:with]
      (o_table, o_field) = options[:other].split('.')
      clauses = ["UPDATE `#{table_name}` t JOIN `#{o_table}` o ON (t.`#{fk}` = o.`#{o_field}`"]
      clauses << "AND t.#{filter_field} = ? AND o.#{filter_field} = t.#{filter_field}" if filter
      clauses << "AND t.#{options[:poly_type]} = ?" if options[:poly_type]
      clauses << ')'
      clauses << "SET t.`#{set}` = o.`#{with_field}`"
      page_size = 64_000 # NOTE: I played around with this value a bit, and this seems an efficient value.
      values << filter if filter
      values << options[:poly_val] if options[:poly_val]
      if max - min > page_size
        clauses << "WHERE t.#{primary_key} >= ? AND t.#{primary_key} <= ?"
        while max > min
          upper = min + page_size - 1
          args = values + [min, upper]
          clean_execute([clauses.join(' '), args])
          min += page_size
        end
      else # no pagination required:
        clean_execute([clauses.join(' '), values])
      end
    end

    def clean_execute(args)
      clean_sql = sanitize_sql(args)
      connection.execute(clean_sql)
    end
  end
end
