class ExcelParser
  # There are many options for gems to use to implement this:
  # https://github.com/pythonicrubyist/creek
  # https://github.com/roo-rb/roo
  # https://github.com/zdavatz/spreadsheet/blob/master/GUIDE.md
  # https://github.com/zenkay/simple-spreadsheet
  # https://github.com/woahdae/simple_xlsx_reader
  #
  # I chose Creek to start with because it claimed to be fastest with large
  # files.

  def initialize(path_to_file, options = {})
    @sheet_num = options[:sheet] || 1
    @sheet_num -= 1
    @header_lines = options[:header_lines] || 1
    @data_begins_on_line = options[:data_begins_on_line] || 1
    @path_to_file = path_to_file
    @file_open = false
    @headers = nil
    @sheet = nil
  end

  def open_file
    return false if @file_open
    @file = Creek::Book.new @path_to_file
    @sheet = @file.sheets[@sheet_num]
    @file_open = true
  end

  def headers
    return @headers if @headers
    open_file
    headers = {}
    @sheet.rows.each_with_index do |row, i|
      break if i >= @header_lines
      row.each do |cell, contents|
        column = cell.gsub(/\d+$/, "")
        headers[column] ||= []
        next unless contents
        headers[column] << contents.gsub(/\r/, " ").gsub(/\n/, " ")
      end
    end
    @headers = []
    headers.each do |_, contents|
      @headers << contents.join(" ").
        # Fix spaces:
        sub(/^\s+/, "").sub(/\s+$/, "").gsub(/\s+/, " ")
    end
    @headers
  end

  def rows_as_hashes(&block)
    open_file
    @sheet.rows.each_with_index do |row, i|
      next if i < @data_begins_on_line
      hash = Hash[headers.zip(row.values)]
      yield(hash, i, false)
    end
  end
end
