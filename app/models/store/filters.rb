module Store
  module Filters
    def remove_emojis(val)
      val.gsub(Unicode::Emoji::REGEX, '')
    end
  end
end
