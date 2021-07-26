RESOURCE_ID = 10

class Generator
  BASE_TRAIT = {
    scientific_name: '<i>Calanus glacialis</i>',
    resource_pk: 1,
    predicate: 'http://eol.org/schema/terms/ProsomeLength',
    sex: 'http://www.ebi.ac.uk/efo/EFO_0001272',
    lifestage: 'http://www.ebi.ac.uk/efo/EFO_0001444',
    statistical_method: nil,
    object_page_id: nil,
    target_scientific_name: nil, 
    value_uri: nil,
    literal: nil,
    measurement: 4.026,
    units: 'http://purl.obolibrary.org/obo/UO_0000016',
    normal_measurement: 4.026,
    normal_units_uri: 'http://purl.obolibrary.org/obo/UO_0000016',
    sample_size: nil,
    citation: nil,
    source: 'https://opendata.eol.org/dataset/arczoo-ld',
    method: 'Direct measurement from specimen photo',
    contributor_uri: 'https://doi.org/10.1007/s12526-010-0080-x',
    computer_uri: 'https://orcid.org/0000-0002-9943-2342',
    determined_by_uri: nil
  }

  def trait_row
    row = BASE_TRAIT.dup

    row[:eol_pk] = trait_pk
    row[:page_id] = page_id

    row
  end

  def trait_pk
    "R10-PK#{random_int(100_000..999_999_999)}"
  end

  def page_id
    random_int(1..10_000_000)
  end

  def random_int(range)
    @rand ||= Random.new
    @rand.rand(range)
  end
end

generator = Generator.new

CSV.open('publish_traits1.tsv', 'wb', headers: Publisher::TRAIT_HEADS, write_headers: true) do |csv1|
  CSV.open('publish_traits2.tsv', 'wb', headers: Publisher::TRAIT_HEADS, write_headers: true) do |csv2|
    (1..2_000_000).each do |i|
      trait1 = generator.trait_row
      trait2 = i % 3 == 0 ? generator.trait_row : trait1  # make every third trait differ
      csv1 << trait1
      csv2 << trait2
    end
  end
end

