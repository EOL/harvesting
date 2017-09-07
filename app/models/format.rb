class Format < ActiveRecord::Base
  has_many :fields, -> { order(represents: :asc) }, inverse_of: :format,
    dependent: :destroy
  has_many :hlogs, inverse_of: :format, dependent: :destroy

  belongs_to :harvest, inverse_of: :formats
  belongs_to :resource, inverse_of: :formats

  enum file_type: [ :excel, :csv ]
  # NOTE: every "represents" needs a corresponding response in #model_fks.
  # NOTE: the order is *deterministic* and as follows:
  # NOTE: we no longer support events.
  enum represents: [ :agents, :refs, :attributions, :nodes, :articles, :images,
    :js_maps, :links, :media, :maps, :sounds, :videos, :vernaculars,
    :scientific_names, :data_occurrences, :data_measurements ]

  acts_as_list scope: :resource

  scope :abstract, -> { where("harvest_id IS NULL") }

  def model_fks
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
      { Ref => :resource_pk }
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
    else
      raise "Unimplemented #model_fks for type #{represents}!"
    end
  end

  def converted_csv_path
    special_path("converted_csv", "csv")
  end

  def copy_to_harvest(new_harvest)
    new_format = self.dup
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
    special_path("diff", "diff")
  end

  # You can pass in :cat, :e, :line as options
  def log(message, options = {})
    options[:cat] ||= :infos
    trace = options[:e] ? options[:e].backtrace.join("\n") : nil
    hlogs << Hlog.create!(format: self,
      harvest: harvest,
      category: options[:cat],
      message: message,
      backtrace: trace,
      line: options[:line]
    )
  end

  def special_path(dir, ext)
    Rails.public_path.join(dir,
      "#{resource.name_brief}_fmt_#{file_type}_#{id}.#{ext}")
  end

  def warn(message, line)
    log(message, line: line, cat: :warns)
  end
end
