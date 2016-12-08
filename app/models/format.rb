class Format < ActiveRecord::Base
  has_many :fields, -> { order(position: :asc) }, inverse_of: :format
  has_many :hlogs, inverse_of: :format

  belongs_to :harvest, inverse_of: :formats
  belongs_to :resource, inverse_of: :formats

  enum file_type: [ :excel, :dwca, :csv ]
  enum represents: [ :articles, :attributions, :images, :js_maps, :links,
    :media, :maps, :refs, :sounds, :videos, :nodes, :vernaculars ]

  def copy_to_harvest(new_harvest)
    new_harvest.formats << self.clone
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
