require 'csv'
# Generalized access to character-separated files. Handles more than just commas; the name is based on the CSV class it
# is derived from.
module CsvParsing

  attr_accessor :path_to_file, :row_sep

  def initialize(path_to_file, options = {})
    @header_lines = options[:header_lines] || 1
    @data_begins_on_line = options[:data_begins_on_line] || 1
    @col_sep = options[:field_sep] || ','
    @row_sep = options[:line_sep] || "\n"
    @path_to_file = path_to_file
    @headers = options[:headers]
  end

  def line_at_a_time
    i = 0
    return false unless File.exist?(@path_to_file)

    quote = '"'
    quote = "\x00" if @col_sep == "\t" # Turns out they like to use "naked" quotes in tab-delimited files.
    @tried = {}
    begin
      CSV.foreach(@path_to_file, col_sep: @col_sep, row_sep: @row_sep, quote_char: quote, encoding: 'UTF-8') do |row|
        next if row.compact.empty?

        yield(row, i)
        i += 1
      end
    rescue CSV::MalformedCSVError => e
      if @row_sep == "\n" && !@tried[:crlf]
        @tried[:crlf] = true
        puts "WARNING: Re-reading #{@path_to_file} with CRLF insteead of LF."
        @row_sep = "\r\n"
      elsif @row_sep == "\r\n" && !@tried[:cr]
        @tried[:cr] = true
        puts "WARNING: Re-reading #{@path_to_file} with CR insteead of CRLF."
        @row_sep = "\r"
      elsif @row_sep == "\r" && !@tried[:lf]
        @tried[:lf] = true
        puts "WARNING: Re-reading #{@path_to_file} with LF insteead of CR."
        @row_sep = "\n"
      else
        raise e
      end
      retry
    end
    true
  end

  def headers
    return @headers if @headers

    headers = []
    offset = 0
    line_at_a_time do |row, i|
      if row.size == 1
        offset += 1
        next
      end
      break if i >= (@header_lines + offset)

      row.each_with_index do |cell, j|
        headers[j] ||= []
        headers[j] << cell&.tr("\r", ' ')&.tr("\n", ' ')
      end
    end
    @headers = []
    headers.each do |contents|
      @headers << contents.join(' ').
                  # Fix spaces:
                  sub(/^\s+/, '').sub(/\s+$/, '').gsub(/\s+/, ' ')
    end
    @headers
  end
end
