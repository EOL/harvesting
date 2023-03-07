module Store
  # These are just methods that can be called by several other "Store" modules.
  module Filters
    def remove_emojis(val)
      val.gsub(Unicode::Emoji::REGEX, '')
    end
  end
end
