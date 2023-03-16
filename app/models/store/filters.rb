module Store
  # These are just methods that can be called by several other "Store" modules.
  module Filters
    def remove_emojis(val)
      # Also Cutting a wide swath of "unsortable" characters and emojis that the DB can't store:
      # q.v.: https://www.fileformat.info/info/unicode/block/index.htm
      val.gsub(/[\u{1D360}-\u{323AF}]/, '')
    end
  end
end
