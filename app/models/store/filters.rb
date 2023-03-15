module Store
  # These are just methods that can be called by several other "Store" modules.
  module Filters
    def remove_emojis(val)
      
      val.gsub(Unicode::Emoji::REGEX, '').
         gsub(/[\u{1d600}-\u{1d6ff}]/, ''). # italicized characters
         gsub(/[\u{2A700}-\u{2BFFF}]/, ''). # Extended Chinese characters
         gsub(/[\u{1D400}-\u{1D7FF}]/, '')  # Mathematical Alphanumeric Symbols
    end
  end
end
