# Each resourvce needs to have several file formats defined... e.g.: taxa, agents, refs, etc. ...This model represents
# those file format definitions.
class Format < ActiveRecord::Base
  default_scope { order(represents: :asc) }

  before_destroy :remove_files

  has_many :fields, -> { order(position: :asc) }, inverse_of: :format, dependent: :destroy
  has_many :hlogs, inverse_of: :format, dependent: :destroy

  belongs_to :harvest, inverse_of: :formats
  belongs_to :resource, inverse_of: :formats

  enum file_type: %i[excel csv]
  # NOTE: every "represents" needs a corresponding response in #model_fks.
  # NOTE: the order is *deterministic* and as follows:
  # NOTE: we no longer support events.
  enum represents: %i[
    agents refs attributions nodes articles images js_maps links media maps sounds videos vernaculars scientific_names
    occurrences assocs measurements
  ]

  scope :abstract, -> { where('harvest_id IS NULL') }

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

  def converted_csv_path
    special_path('converted_csv', 'csv')
  end

  def copy_to_harvest(new_harvest)
    new_format = self.dup # rubocop:disable Style/RedundantSelf
    new_harvest.formats << new_format
    fields.each do |field|
      new_field = field.dup
      # TODO: see if these two commands are redundant:
      new_field.format_id = new_format.id
      new_format.fields << new_field
      new_field.save!
    end
    new_format.save!
    new_format
  end

  def diff_path
    special_path('diff', 'diff')
  end

  # You can pass in :cat, :e, :line as options
  def log(message, options = {})
    harvest.log(message, options.merge(format: self))
  end

  def special_path(dir, ext)
    Rails.public_path.join(dir, "#{resource.name_brief}_#{represents}_#{id}.#{ext}")
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

  def open_converted_csv
    CSV.read(converted_csv_path, encoding: 'ISO-8859-1')
  end

  def file_parser
    raise "File missing!" unless File.exist?(file)
    parser =
      if excel?
        ExcelParser.new(file, sheet: sheet, header_lines: header_lines, data_begins_on_line: data_begins_on_line)
      elsif csv?
        CsvParser.new(file, field_sep: field_sep, line_sep: line_sep, header_lines: header_lines,
                            data_begins_on_line: data_begins_on_line)
      else
        raise "I don't know how to read formats of #{file_type}!"
      end
  end

  def diff_parser
    CsvParser.new(diff)
  end

  def remove_files
    File.unlink(converted_csv_path) if File.exist?(converted_csv_path)
    File.unlink(diff_path) if File.exist?(diff_path)
  end
end
