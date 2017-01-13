class ScientificName < ActiveRecord::Base
  belongs_to :resource, inverse_of: :scientific_names
  belongs_to :node, inverse_of: :scientific_names
  # TODO: belongs_to :normalized_name

  has_many :nodes, inverse_of: :scientific_name

  # This list was captured from the document Katja produced (this link may
  # not work for all):
  # https://docs.google.com/spreadsheets/d/1qgjUrFQQ8JHLtcVcZK7ClV3mlcZxxObjb5SXkr5FAUUqrr
  enum taxonomic_status: [ :preferred, :provisionally_accepted, :acronym,
    :synonym, :unusable ]

  scope :published, -> { where(removed_by_harvest_id: nil) }
end
