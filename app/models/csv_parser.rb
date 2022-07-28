require 'csv'
# Generalized access to character-separated files. Handles more than just commas; the name is based on the CSV class it
# is derived from.
class CsvParser

  include CsvParsing

  def rows_as_hashes
    offset = 0
    hash = nil
    line_at_a_time do |row, i|
      offset += 1 if row.size == 1 && hash.nil?
      next if i < (@data_begins_on_line + offset)

      hash = Hash[headers.zip(row)]
      yield(hash, i)
    end
  end
end
