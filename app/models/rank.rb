class Rank
  class << self
    attr_accessor :ordered, :unordered

    def add_prefixes(basenames)
      basenames.flat_map { |b| @prefixes.map { |p| p == '-' ? b : "#{p}#{b}" } }
    end

    def sort(array)
      scores = {}
      array.each do |el|
        scores[el] = ordered.index(el.downcase.gsub(/\s/, ''))
      end
      array.sort do |a,b|
        if scores[a].nil? || scores[b].nil?
          0
        else
          scores[a] <=> scores[b]
        end
      end
    end
  end

  # These were provided by Katja and are in order:
  @base_names = %w[
    domain
    kingdom
    phylum
    class
    cohort
    division
    order
    family
    tribe
    genus] + ["species group"] + %w[
    species
    variety
    form
  ]

  @groups = 'paraphyletic group' + 'polyphyletic group'

  @prefixes = %w[mega super epi - sub infra subter]
  @ordered = Rank.add_prefixes(@base_names)
  @unordered_base_names = %w[section series clade]
  @unordered = Rank.add_prefixes(@unordered_base_names)

end
