class Format < ActiveRecord::Base
  has_many :fields, -> { order(position: :asc) }, inverse_of: :format
  has_many :hlogs, inverse_of: :format

  belongs_to :harvest, inverse_of: :formats
  belongs_to :resource, inverse_of: :formats

  enum file_type: [ :excel, :dwca, :csv ]
  enum represents: [ :articles, :attributions, :images, :js_maps, :links,
    :media, :maps, :refs, :sounds, :videos, :nodes, :vernaculars,
    :scientific_names ]

  acts_as_list scope: :resource

  scope :abstract, -> { where("harvest_id IS NULL") }

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

  def warn(message, line)
    log(message, line: line, cat: :warns)
  end
end
