require 'csv'
class CsvParser
  def initialize(path_to_file, options = {})
    @header_lines = options[:header_lines] || 1
    @data_begins_on_line = options[:data_begins_on_line] || 1
    @col_sep = options[:field_sep] || ","
    @row_sep = options[:line_sep] || "\n"
    @path_to_file = path_to_file
    @headers = nil
  end

  def line_at_a_time(&block)
    i = 0
    CSV.foreach(@path_to_file, col_sep: @col_sep, row_sep: @row_sep) do |row|
      yield(row, i)
      i += 1
    end
  end

  def headers
    return @headers if @headers
    headers = []
    line_at_a_time do |row, i|
      break if i >= @header_lines
      row.each_with_index do |cell, j|
        headers[j] ||= []
        headers[j] << cell.gsub(/\r/, " ").gsub(/\n/, " ")
      end
    end
    @headers = []
    headers.each do |contents|
      @headers << contents.join(" ").
        # Fix spaces:
        sub(/^\s+/, "").sub(/\s+$/, "").gsub(/\s+/, " ")
    end
    @headers
  end

  def rows_as_hashes(&block)
    line_at_a_time do |row, i|
      next if i < @data_begins_on_line
      hash = Hash[headers.zip(row)]
      yield(hash, i)
    end
  end
end
