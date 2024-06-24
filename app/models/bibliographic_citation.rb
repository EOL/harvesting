class BibliographicCitation < ApplicationRecord
  establish_connection Rails.env.to_sym
  has_many :media, inverse_of: :bibliographic_citation
  has_many :articles, inverse_of: :bibliographic_citation

  def name # note: just a standard way of outputting an objects "name" briefly...
    body
  end
end
