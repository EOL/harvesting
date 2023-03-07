module Store
  # These are just methods that can be called by several other "Store" modules.
  module Filters
    def remove_emojis(val)
      # NOTE: this gives a deprecated constant warning, but I swear it's really not: https://github.com/ticky/ruby-emoji-regex
      val.gsub(EmojiRegex::Regex, '')
    end
  end
end
