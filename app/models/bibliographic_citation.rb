class BibliographicCitation < ActiveRecord::Base
  has_many :media, inverse_of: :bibliographic_citation

  def name # note: just a standard way of outputting an objects "name" briefly...
    body
  end
end
