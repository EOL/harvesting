class Medium < ActiveRecord::Base
  belongs_to :resource, inverse_of: :media
  belongs_to :node, inverse_of: :media
  # belongs_to :license
  belongs_to :language
  # belongs_to :location
  # belongs_to :bibliographic_citation

  enum subclass: [:image, :video, :sound, :map_image ]
  enum format: [:jpg, :youtube, :flash, :vimeo, :mp3, :ogg, :wav]
end
