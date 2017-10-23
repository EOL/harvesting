module Store
  # Methods describing booleans. Aren't you glad I included this comment?!
  module Boolean
    # NOTE:
    def looks_true?(val)
      if val =~ /^[+ty1✓✓x]/i || # Trying to capture "true", "yes", "1", chekmarks and "+", here.
         val =~ /(true|yes)$/i # ...and this is meant for "URIs" that end in these terms.
        true
      else
        false
      end
    end
  end
end
