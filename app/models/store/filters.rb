module Store
  # These are just methods that can be called by several other "Store" modules.
  module Filters
    def remove_emojis(val)
      # The second set removes italicized characters, which are also not allowed in the DB.
      val.gsub(Unicode::Emoji::REGEX, '').gsub(/[\u{1d600}-\u{1d6ff}]/, '')
    end
  end
end
