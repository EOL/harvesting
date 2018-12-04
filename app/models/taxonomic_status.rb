class TaxonomicStatus
  class << self
    attr_accessor :inverse_map, :regexes
  end

  @inverse_map = {
    preferred: ['preferred', 'accepted', 'valid'],
    provisionally_accepted: ['provisionally accepted'],
    alternative: [
      'anamorph',
      'genbank anamorph',
      'teleomorph',
      'senior synonym',
      'nomen dubium',
      'species inquirenda'
    ],
    synonym: [
      'acronym',
      'authority',
      'basionym',
      'equivalent',
      'genbank acronym',
      'genbank synonym',
      'heterotypic synonym',
      'heterotypicsynonym',
      'homonym & junior synonym',
      'homonym (illegitimate)',
      'homotypic synonym',
      'incorrect authority information',
      'incorrect spelling',
      'junior homonym',
      'junior synonym',
      'lexical variant',
      'misspelling',
      'not accepted',
      'objective synonym',
      'original name/combination',
      'orthographic variant',
      'other, see comments',
      'rejected',
      'spelling alternative',
      'subjective synonym',
      'subsequent name/combination',
      'superfluous renaming (illegitimate)',
      'synonym',
      'invalidly published',
      'nomen oblitum',
      'unavailable',
      'unjustified emendation',
      'unnecessary replacement',
      'unpublished',
      'invalid',
      'genus synonym',
      'alternate representation',
      'unavailable',
      'uncertain',
      'unspecified in provided data'
    ],
    unusable: [
      'blast',
      'common',
      'database artifact',
      'genbank common',
      'other',
      'unavailable, database artifact',
      'misapplied',
      'ambiguous synonym',
      'in-part',
      'includes',
      'pro parte',
      'type material'
    ]
  }

  @regexes = {
    /^orthographic variant.*/ => 'orthographic variant',
    /^synonym.*/ => 'synonym',
    /^invalidly published.*/ => 'invalidly published',
    /^unavailable.*/ => 'unavailable'
  }

  class << self
    def types
      @inverse_map.keys
    end

    def map
      return @map if @map
      @map = {}
      @inverse_map.each { |k, a| a.each { |v| @map[v] = k } }
      @map
    end

    def parse(verbatim)
      return nil if verbatim.nil?
      # NOTE: lowercase, normalizes spaces, removes "name" at the end.
      string = normalize(verbatim)
      regexes.each do |re, normalized|
        string = normalized if string.to_s =~ re
      end
      # TODO: rearrange this once we know how to handle missing keys
      return map[string] if map.key?(string)
      raise Errors::UnmatchedTaxonomicStatus, string
    end

    def normalize(verbatim)
      verbatim.to_s.downcase.gsub(/\s+/, ' ').sub(/^\s+/, '').sub(/\s+$/, '').sub(/ name$/, '')
    end

    def preferred?(verbatim)
      string = normalize(verbatim)
      map.key?(string) && map[string] == :preferred # TODO: include provisionally_accepted and alternative
    end
  end
end
