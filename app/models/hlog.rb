class Hlog < ActiveRecord::Base
  belongs_to :harvest, inverse_of: :hlogs
  belongs_to :format, inverse_of: :hlogs

  enum category: %i[errors warns infos progs loops starts ends counts queries commands names_matches]
end
