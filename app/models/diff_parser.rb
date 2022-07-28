require 'csv'
# Generalized access to character-separated files. Handles more than just commas; the name is based on the CSV class it
# is derived from.
class DiffParser

  include CsvParsing

  CHANGED_ROW = /^[><]/

  def diff_as_hashes(db_headers)
    any_diff = line_at_a_time do |row, line|
      next unless row.first =~ CHANGED_ROW

      yield(row_as_diff(row, db_headers))
    end
    any_diff
  end

  def row_as_diff(row, headers)
    type = :error
    if row.first # Because if it's nil, then we're looking at an empty first field, which is ok.
      type = if row.first.sub!(/^> /, '')
        :new
      elsif row.first.sub!(/^< /, '')
        :old
      end
    end
    hash = Hash[headers.zip(row)]
    hash[:type] = type
    hash
  end
end
