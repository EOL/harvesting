module Store
  class << self
    def is_truthy?(verbatim)
      # Since a file will tend to use exactly the same values, remember what
      # they like:
      @@truthiness ||= {}
      return @@truthiness[verbatim] if @@truthiness.has_key?(verbatim)
      @@truthiness[verbatim] = is_truthy_uncached?(verbatim)
    end

    def is_truthy_uncached?(verbatim)
      val = verbatim.downcase
      # Some "simple" (fast) checks on most common values:
      return true if val == 'true'
      return false if val == 'false'
      return true if val == '1'
      return false if val == '0'
      return true if val == 'yes'
      return false if val == 'no'
      # TODO: there are some URIs which are common and we should check them
      # here.
      # ...and we didn't find anything, so clean up and check again:
      stripped = val.gsub(/\s+/, '')
      return true if stripped =~ /\btrue/
      return false if stripped =~ /\bfalse/
      return true if stripped == '1'
      return false if stripped == '0'
      return true if stripped =~ /\byes\b/
      return false if stripped =~ /\bno\b/
    end
  end
end
