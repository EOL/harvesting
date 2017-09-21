class Rank
  class << self
    attr_accessor :strings
  end

  @strings = %w[
    domain
    subdomain
    infradomain

    superkingdom
    kingdom
    subkingdom
    infrakingdom

    superphylum
    phylum
    subphylum
    infraphylum

    superdivision
    division
    subdivision
    infradivision

    superclass
    class
    subclass
    infraclass

    superorder
    order
    suborder
    infraorder

    superfamily
    family
    subfamily
    infrafamily

    tribe

    supergenus
    genus
    subgenus
    infragenus

    superspecies
    species
    subspecies
    infraspecies
    variety
    form
  ]

  def self.sort(array)
    scores = {}
    array.each do |el|
      scores[el] = strings.index(el.downcase.gsub(/\s/, ''))
      puts "NOPE: #{el}" if scores[el].nil?
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
