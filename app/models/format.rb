# Each resource needs to have several file formats defined... e.g.: taxa, agents, refs, etc. ...This model represents
# those file format definitions.
class Format < ApplicationRecord
  default_scope { order(represents: :asc) }

  has_many :fields, -> { order(position: :asc) }, inverse_of: :format, dependent: :delete_all

  belongs_to :resource, inverse_of: :formats

  enum file_type: %i[excel csv]
  # NOTE: every "represents" needs a corresponding response in #model_fks.
  # NOTE: the order is *deterministic* and as follows:
  # NOTE: we no longer support events.
  enum represents: %i[
    agents refs attributions nodes articles images js_maps links media maps sounds videos vernaculars scientific_names
    occurrences assocs measurements
  ]

  def model_fks # rubocop:disable Metrics/MethodLength Metrics/CyclomaticComplexity
    if articles?
      { Article => :resource_pk }
    elsif attributions?
      { Attribution => :resource_pk }
    elsif images?
      { Medium => :resource_pk }
    elsif js_maps?
      { Medium => :resource_pk }
    elsif links?
      { Link => :resource_pk }
    elsif media?
      { Medium => :resource_pk }
    elsif maps?
      { Medium => :resource_pk }
    elsif refs?
      { Reference => :resource_pk }
    elsif sounds?
      { Medium => :resource_pk }
    elsif videos?
      { Medium => :resource_pk }
    elsif nodes?
      { Node => :resource_pk }
    elsif vernaculars?
      { Vernacular => :verbatim }
    elsif scientific_names?
      { ScientificName => :verbatim }
    elsif occurrences?
      { Occurrence => :resource_pk }
    elsif measurements?
      { Trait => :resource_pk }
    else
      raise "Unimplemented #model_fks for type #{represents}!"
    end
  end

  # You can pass in :cat, :e, :line as options (q.v. Harvest)
  def log(message, options = {})
    harvest.log(message, options.merge(format: self))
  end

  def warn(message, line = nil)
    log(message, line: line, cat: :warns)
  end

  def name
    "#{represents} for #{resource.name}"
  end

  def headers
    fields.sort_by(&:position).map(&:expected_header)
  end

  def file_parser
    use_original_file if file.nil?
    raise "File missing: #{file}" unless File.exist?(file)

    if excel?
      ExcelParser.new(file, sheet: sheet, header_lines: header_lines, data_begins_on_line: data_begins_on_line)
    elsif csv?
      headers = nil
      headers = fields.map(&:expected_header) if data_begins_on_line.zero?
      CsvParser.new(file, field_sep: field_sep, line_sep: line_sep, header_lines: header_lines,
                          data_begins_on_line: data_begins_on_line, headers: headers)
    else
      raise "I don't know how to read formats of #{file_type}!"
    end
  end

  def use_original_file
    update_attribute(:file, get_from)
  end
end
