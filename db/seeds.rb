tmp_path = Rails.root.join('tmp')
diff_path = Rails.public_path.join('diff')
Dir.glob("#{tmp_path}/names*").each { |file| File.unlink(file) }
Dir.glob("#{diff_path}/*.diff").each { |file| File.unlink(file) }

Rails.cache.clear
License.public_domain

file = Rails.root.join('db', 'data', 'datasets.csv')
if File.exist?(file)
  puts '.. Importing datasets'
  datasets = []
  headers = nil
  CSV.foreach(file, encoding: 'ISO-8859-1') do |row|
    if headers.nil?
      headers = row
    else
      data = {}
      row.each_with_index do |field, i|
        data[headers[i]] = field
      end
      datasets << data
    end
  end
  Dataset.import(datasets)
else
  puts "NO datasets file found (#{file}), skipping. Your names attributions may be missing."
end

terms_file = Rails.public_path.join('data', 'terms.json')
if File.exist?(terms_file)
  Term.delete_all
  puts '.. Importing terms'
  json = JSON.parse(File.read(terms_file))
  Term.from_json(json)
else
  puts "No terms file found (#{terms_file}), skipping. Your term URIs will not be defined."
end

eol_attrs = {
  name: 'Encyclopedia of Life',
  abbr: 'EOL',
  short_name: 'EOL',
  homepage_url: 'http://eol.org',
  description: 'A webpage for every species. Or something like that.',
  auto_publish: true
}

Resource.quick_define(
  name: 'EOL Dynamic Hierarchy',
  abbr: 'DWH',
  type: :csv,
  partner: eol_attrs,
  field_sep: "\t",
  pk_url: 'http://eol.org/$PK&but=not_really',
  base_dir: Rails.public_path.join('data', 'dwh'),
  formats: {
    nodes: { loc: 'taxa.txt', fields: [
      { 'taxonID' => 'to_nodes_pk', is_unique: true, can_be_empty: false },
      { 'acceptedNameUsageID' => 'to_nodes_accepted_name_fk' },
      { 'parentNameUsageID' => 'to_nodes_parent_fk' },
      { 'scientificName' => 'to_nodes_scientific' },
      { 'taxonRank' => 'to_nodes_rank' },
      { 'source' => 'to_ignored' },
      { 'taxonomicStatus' => 'to_taxonomic_status' },
      { 'canonicalName' => 'to_ignored' }, # TODO: see note in your to do list. ;)
      { 'scientificNameAuthorship' => 'to_ignored' },
      { 'scientificNameID' => 'to_nodes_identifiers' },
      { 'taxonRemarks' => 'to_nodes_remarks' },
      { 'namePublishedIn' => 'to_nodes_publication' },
      { 'furtherInformationURL' => 'to_nodes_further_information_url' },
      { 'datasetID' => 'to_nodes_dataset_id' },
      { 'EOLid' => 'to_nodes_page_id' },
      { 'EOLidAnnotations' => 'to_ignored' },
      { 'Landmark' => 'to_nodes_landmark'}
    ] }
  }
)

resource = Resource.where(name: 'Test CSV').first_or_create do |r|
  r.position = 1
  r.name = 'Test CSV'
  r.abbr = 'CSV'
end

fmt = Format.where(resource_id: resource.id, represents: Format.represents[:nodes])
            .abstract
            .first_or_create do |f|
              f.resource_id = resource.id
              f.represents = Format.represents[:nodes]
              f.file_type = Format.file_types[:csv]
              f.get_from = 'http://example.com/path/to_file.csv'
            end

Field.where(format_id: fmt.id, position: 1).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 1
  f.validation = Field.validations[:must_be_integers]
  f.expected_header = 'TID'
  f.mapping = 'to_nodes_pk'
  f.unique_in_format = true
  f.can_be_empty = false
end

Field.where(format_id: fmt.id, position: 2).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 2
  f.expected_header = 'Kingdom'
  f.mapping = 'to_nodes_ancestor'
  f.submapping = 'kingdom'
end

Field.where(format_id: fmt.id, position: 3).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 3
  f.expected_header = 'SciName'
  f.mapping = 'to_nodes_scientific'
  f.unique_in_format = true
  f.can_be_empty = false
end

# Apologies for the long 'comment', but this describes the Excel file's format,
# so it's useful:

sheets = {
sheet1_images: [
  'MediaID http://purl.org/dc/terms/identifier', # media_pk
  'TaxonID http://rs.tdwg.org/dwc/terms/taxonID', # to_media_nodes_fk
  'Type http://purl.org/dc/terms/type', # media_type
  'Subtype http://rs.tdwg.org/audubon_core/subtype', # to_ignored
  'Format http://purl.org/dc/terms/format', # format
  'Subject http://iptc.org/std/Iptc4xmpExt/1.0/xmlns/CVterm', # section
  'Title http://purl.org/dc/terms/title', # media_name
  'Description http://purl.org/dc/terms/description',  # media_description
  'AccessURI http://rs.tdwg.org/ac/terms/accessURI', # media_source_url
  'ThumbnailURL http://eol.org/schema/media/thumbnailURL', # to_ignored (we build our own)
  'FurtherInformationURL http://rs.tdwg.org/ac/terms/furtherInformationURL', # media_source_page_url
  'DerivedFrom http://rs.tdwg.org/ac/terms/derivedFrom', # derived_from_reference
  'CreateDate http://ns.adobe.com/xap/1.0/CreateDate', # to_ignored
  'Modified http://purl.org/dc/terms/modified', # to_ignored
  'Language http://purl.org/dc/terms/language', # to_language_639_1
  'Rating http://ns.adobe.com/xap/1.0/Rating', # to_ignored
  'Audience http://purl.org/dc/terms/audience', # to_ignored
  'License http://ns.adobe.com/xap/1.0/rights/UsageTerms', # to_media_license
  'Rights http://purl.org/dc/terms/rights', # media_rights_statement
  'Owner http://ns.adobe.com/xap/1.0/rights/Owner', # media_owner
  'BibliographicCitation http://purl.org/dc/terms/bibliographicCitation', # bibliographic_citation
  'Publisher http://purl.org/dc/terms/publisher', # to_attribution submapping: publisher
  'Contributor http://purl.org/dc/terms/contributor', # to_attribution submapping: contributor
  'Creator http://purl.org/dc/terms/creator', # to_attribution submapping: creator
  'AgentID http://eol.org/schema/agent/agentID', # to_attributions_fk
  'LocationCreated http://iptc.org/std/Iptc4xmpExt/1.0/xmlns/LocationCreated', # location
  'GenericLocation http://purl.org/dc/terms/spatial', # loc_verbatim
  'Latitude http://www.w3.org/2003/01/geo/wgs84_pos#lat', # loc_lat
  'Longitude http://www.w3.org/2003/01/geo/wgs84_pos#long', # loc_long
  'Altitude http://www.w3.org/2003/01/geo/wgs84_pos#alt', # loc_alt
  'ReferenceID http://eol.org/schema/reference/referenceID' # to_ignored (because only articles now allow this)
],
sheet2_nodes: [
  'Identifier http://rs.tdwg.org/dwc/terms/taxonID', # to_nodes_pk
  'ScientificName http://rs.tdwg.org/dwc/terms/scientificName', # to_nodes_scientific
  'Parent TaxonID http://rs.tdwg.org/dwc/terms/parentNameUsageID', # to_nodes_parent_fk
  'Kingdom http://rs.tdwg.org/dwc/terms/kingdom', # to_nodes_ancestor submapping: kingdom
  'Phylum http://rs.tdwg.org/dwc/terms/phylum', # to_nodes_ancestor submapping: phylum
  'Class http://rs.tdwg.org/dwc/terms/class', # to_nodes_ancestor submapping: class
  'Order http://rs.tdwg.org/dwc/terms/order', # to_nodes_ancestor submapping: order
  'Family http://rs.tdwg.org/dwc/terms/family', # to_nodes_ancestor submapping: family
  'Genus http://rs.tdwg.org/dwc/terms/genus', # to_nodes_ancestor submapping: genus
  'TaxonRank http://rs.tdwg.org/dwc/terms/taxonRank', # to_nodes_rank
  'FurtherInformationURL http://rs.tdwg.org/ac/terms/furtherInformationURL', # to_nodes_further_information_url
  'TaxonomicStatus http://rs.tdwg.org/dwc/terms/taxonomicStatus', # to_taxonomic_status
  'TaxonRemarks http://rs.tdwg.org/dwc/terms/taxonRemarks', # to_nodes_remarks
  'NamePublishedIn http://rs.tdwg.org/dwc/terms/namePublishedIn', # to_nodes_publication
  'ReferenceID http://eol.org/schema/reference/referenceID' #to_nodes_ref_fks
],
sheet3_names: [
  'TaxonID http://rs.tdwg.org/dwc/terms/taxonID', # to_media_nodes_fk
  'Name http://rs.tdwg.org/dwc/terms/vernacularName', # to_vernaculars_verbatim
  'Source Reference http://purl.org/dc/terms/source', # to_vernaculars_source
  'Language http://purl.org/dc/terms/language', # to_language_639_1
  'Locality http://rs.tdwg.org/dwc/terms/locality', # to_vernaculars_locality
  'CountryCode http://rs.tdwg.org/dwc/terms/countryCode', # to_vernaculars_locality
  'IsPreferredName http://rs.gbif.org/terms/1.0/isPreferredName', # to_vernaculars_preferred
  'TaxonRemarks http://rs.tdwg.org/dwc/terms/taxonRemarks' # to_vernaculars_remarks
],
sheet4_literature_references: [
  'ReferenceID http://purl.org/dc/terms/identifier', # to_refs_pk
  'PublicationType http://eol.org/schema/reference/publicationType', # to_ignored
  'Full Reference http://eol.org/schema/reference/full_reference',
  'PrimaryTitle http://eol.org/schema/reference/primaryTitle', # to_ignored
  'SecondaryTitle http://purl.org/dc/terms/title', # to_ignored
  'Pages http://purl.org/ontology/bibo/pages', # to_ignored
  'PageStart http://purl.org/ontology/bibo/pageStart', # to_ignored
  'PageEnd http://purl.org/ontology/bibo/pageEnd', # to_ignored
  'Volume http://purl.org/ontology/bibo/volume', # to_ignored
  'Edition http://purl.org/ontology/bibo/edition', # to_ignored
  'Publisher http://purl.org/dc/terms/publisher', # to_ignored
  'AuthorList http://purl.org/ontology/bibo/authorList', # to_ignored
  'EditorList http://purl.org/ontology/bibo/editorList', # to_ignored
  'DateCreated http://purl.org/dc/terms/created', # to_ignored
  'Language http://purl.org/dc/terms/language', # to_ignored
  'URL http://purl.org/ontology/bibo/uri', # to_refs_url
  'DOI http://purl.org/ontology/bibo/doi', # to_refs_doi
  'LocalityOfPublisher http://schemas.talis.com/2005/address/schema#localityName' # to_ignored
],
sheet5_agents: [
  'AgentID http://purl.org/dc/terms/identifier', # to_attributions_pk
  'Full Name http://xmlns.com/foaf/spec/#term_name', # to_attributions_name
  'First Name http://xmlns.com/foaf/spec/#term_firstName', # to_ignored
  'Family Name http://xmlns.com/foaf/spec/#term_familyName', # to_ignored
  'Role http://eol.org/schema/agent/agentRole', # to_attributions_role
  'Email http://xmlns.com/foaf/spec/#term_mbox', # to_attributions_email
  'Homepage http://xmlns.com/foaf/spec/#term_homepage', # to_attributions_url
  'Logo URL http://xmlns.com/foaf/spec/#term_logo', # to_ignored
  'Project http://xmlns.com/foaf/spec/#term_currentProject', # to_ignored
  'Organization http://eol.org/schema/agent/organization', # to_ignored
  'AccountName http://xmlns.com/foaf/spec/#term_accountName', # to_ignored
  'OpenID http://xmlns.com/foaf/spec/#term_openid' # to_ignored
],
sheet6_metadata_ignore_also_only_one_header_line: [
  'Agent Roles', 'Data Types', 'Data Subtyes', 'Subjects', 'Licenses', 'Ranks',
  'TaxonStatus', 'Audiences'
] }

excel_resource = Resource.where(name: 'Test Excel').first_or_create do |r|
  r.position = 2
  r.name = 'Test Excel'
  r.abbr = 'XL'
end

fmt = Format.where(
      resource_id: excel_resource.id,
      represents: Format.represents[:nodes]).
    abstract.
    first_or_create do |f|
  f.resource_id = excel_resource.id
  f.represents = Format.represents[:nodes]
  f.sheet = 2
  f.header_lines = 1
  f.data_begins_on_line = 9
  f.file_type = Format.file_types[:excel]
  f.get_from = Rails.root.join('spec', 'files', 't.xlsx')
end

Field.where(format_id: fmt.id, position: 1).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 1
  f.expected_header = 'Identifier'
  f.mapping = 'to_nodes_pk'
  f.unique_in_format = true
  f.can_be_empty = false
end

Field.where(format_id: fmt.id, position: 2).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 2
  f.expected_header = 'ScientificName'
  f.mapping = 'to_nodes_scientific'
  f.unique_in_format = true
  f.can_be_empty = false
end

Field.where(format_id: fmt.id, position: 3).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 3
  f.expected_header = 'Parent TaxonID'
  f.mapping = 'to_nodes_parent_fk'
end

Field.where(format_id: fmt.id, position: 4).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 4
  f.expected_header = 'Kingdom'
  f.mapping = 'to_nodes_ancestor'
  f.submapping = 'kingdom'
end

Field.where(format_id: fmt.id, position: 5).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 5
  f.expected_header = 'Phylum'
  f.mapping = 'to_nodes_ancestor'
  f.submapping = 'phylum'
end

Field.where(format_id: fmt.id, position: 6).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 6
  f.expected_header = 'Class'
  f.mapping = 'to_nodes_ancestor'
  f.submapping = 'class'
end

Field.where(format_id: fmt.id, position: 7).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 7
  f.expected_header = 'Order'
  f.mapping = 'to_nodes_ancestor'
  f.submapping = 'order'
end

Field.where(format_id: fmt.id, position: 8).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 8
  f.expected_header = 'Family'
  f.mapping = 'to_nodes_ancestor'
  f.submapping = 'family'
end

Field.where(format_id: fmt.id, position: 9).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 9
  f.expected_header = 'Genus'
  f.mapping = 'to_nodes_ancestor'
  f.submapping = 'genus'
end

Field.where(format_id: fmt.id, position: 10).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 10
  f.expected_header = 'TaxonRank'
  f.mapping = 'to_nodes_rank'
end

Field.where(format_id: fmt.id, position: 11).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 11
  f.expected_header = 'FurtherInformationURL'
  f.mapping = 'to_nodes_further_information_url'
end

Field.where(format_id: fmt.id, position: 12).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 12
  f.expected_header = 'TaxonomicStatus'
  f.mapping = 'to_taxonomic_status'
end

Field.where(format_id: fmt.id, position: 13).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 13
  f.expected_header = 'TaxonRemarks'
  f.mapping = 'to_nodes_remarks'
end

Field.where(format_id: fmt.id, position: 14).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 14
  f.expected_header = 'NamePublishedIn'
  f.mapping = 'to_nodes_publication'
end

Field.where(format_id: fmt.id, position: 15).first_or_create do |f|
  f.format_id = fmt.id
  f.position = 15
  f.expected_header = 'ReferenceID'
  f.mapping = 'to_nodes_ref_fks'
end

# Okay, I want to be able to create these things (much) faster:
simple_resource = Resource.quick_define(
  name: 'Simple Deltas',
  type: :csv,
  base_dir: Rails.root.join('spec', 'files'),
  formats: {
    nodes: { loc: 't_d_nodes.csv', fields: [
      { 'TID' => 'to_nodes_pk', is_unique: true, can_be_empty: false },
      { 'SciName' => 'to_nodes_scientific', can_be_empty: false },
      { 'Kingdom' => 'to_nodes_ancestor', submapping: 'kingdom' },
      { 'Phylum' => 'to_nodes_ancestor', submapping: 'phylum' },
      { 'Class' => 'to_nodes_ancestor', submapping: 'class' },
      { 'Order' => 'to_nodes_ancestor', submapping: 'order' },
      { 'Family' => 'to_nodes_ancestor', submapping: 'family' },
      { 'Genus' => 'to_nodes_ancestor', submapping: 'genus' },
      { 'Rank' => 'to_nodes_rank' }
    ] },
    media: { loc: 't_d_media.csv', fields: [
      { 'MID' => 'to_media_pk', is_unique: true, can_be_empty: false },
      { 'TID' => 'to_media_nodes_fk', can_be_empty: false },
      { 'type' => 'to_media_type' },
      { 'name' => 'to_media_name' },
      { 'description' => 'to_media_description' },
      { 'source' => 'to_media_source_url' }
    ] },
    vernaculars: { loc: 't_d_names.csv', fields: [
      { 'TID' => 'to_vernacular_nodes_fk', can_be_empty: false },
      { 'name' => 'to_vernaculars_verbatim' },
      { 'language' => 'to_vernaculars_language', submapping: 'en' },
      { 'preferred' => 'to_vernaculars_preferred' }
    ] }
  }
)

if(false)
  resource = Resource.where(name: 'Simple Deltas').first
  resource.formats.each do |f|
    f.update_attribute(:get_from, f.get_from.sub(/_v2/, ''))
  end
  resource.starts.each { |h| h.destroy }
  harvester = ResourceHarvester.new(resource)
  harvester.start
  # Deltas:
  resource.formats.each do |f|
    f.update_attribute(:get_from, f.get_from.sub(/\./, '_v2.'))
  end
  harvester = ResourceHarvester.new(resource)
  harvester.start
end

Resource.quick_define(
  name: 'Mineralogy',
  abbr: 'Mineralogy',
  type: :csv,
  field_sep: "\t",
  pk_url: 'http://some.cool.url/with/a/path/to_$PK.html',
  base_dir: Rails.root.join('spec', 'files', 'mineralogy'),
  formats: {
    nodes: { loc: 'taxon.tsv', fields: [
      { 'taxonID' => 'to_nodes_pk', is_unique: true, can_be_empty: false },
      { 'furtherInformationURL' => 'to_ignored' },
      { 'referenceID' => 'to_ignored' },
      { 'parentNameUsageID' => 'to_nodes_parent_fk' },
      { 'scientificName' => 'to_nodes_scientific', can_be_empty: false },
      { 'namePublishedIn' => 'to_ignored' },
      { 'phylum' => 'to_nodes_ancestor', submapping: 'phylum' },
      { 'class' => 'to_nodes_ancestor', submapping: 'class' },
      { 'order' => 'to_nodes_ancestor', submapping: 'order' },
      { 'family' => 'to_nodes_ancestor', submapping: 'family' },
      { 'genus' => 'to_nodes_ancestor', submapping: 'genus' },
      { 'taxonRank' => 'to_nodes_rank' },
      { 'taxonomicStatus' => 'to_ignored' },
      { 'taxonRemarks' => 'to_ignored' }
    ] },
    occurrences: { loc: 'occurrence.tsv', fields: [
      { 'occurrenceID' => 'to_occurrences_pk', can_be_empty: false, is_unique: true },
      { 'taxonID' => 'to_occurrences_nodes_fk', can_be_empty: false },
      { 'eventID' => 'to_ignored' },
      { 'institutionCode' => 'to_ignored' },
      { 'collectionCode' => 'to_ignored' },
      { 'catalogNumber' => 'to_ignored' },
      { 'sex' => 'to_occurrences_sex' },
      { 'lifeStage' => 'to_occurrences_lifestage' },
      { 'reproductiveCondition' => 'to_occurrences_meta',
        submapping: 'http://rs.tdwg.org/dwc/terms/reproductiveCondition' },
      { 'behavior' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/behavior' },
      { 'establishmentMeans' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/establishmentMeans' },
      { 'occurrenceRemarks' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/occurrenceRemarks' },
      { 'individualCount' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/individualCount' },
      { 'preparations' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/preparations' },
      { 'fieldNotes' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/fieldNotes' },
      { 'samplingProtocol' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/samplingProtocol' },
      { 'samplingEffort' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/samplingEffort' },
      { 'recordedBy' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/recordedBy' },
      { 'identifiedBy' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/identifiedBy' },
      { 'dateIdentified' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/dateIdentified' },
      { 'eventDate' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/eventDate' },
      { 'modified' => 'to_occurrences_meta', submapping: 'http://purl.org/dc/terms/modified' },
      { 'locality' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/locality' },
      { 'decimalLatitude' => 'to_occurrences_lat' },
      { 'decimalLongitude' => 'to_occurrences_long' },
      { 'verbatimLatitude' => 'to_occurrences_lat_literal' },
      { 'verbatimLongitude' => 'to_occurrences_long_literal' },
      { 'verbatimElevation' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/verbatimElevation' }
    ] },
    measurements: { loc: 'measurement_or_fact.tsv', fields: [
      { 'measurementID' => 'to_traits_pk', can_be_empty: false, is_unique: true },
      { 'occurrenceID' => 'to_traits_occurrence_fk' },
      { 'measurementOfTaxon' => 'to_traits_measurement_of_taxon' },
      { 'associationID' => 'to_traits_assoc_node_fk' },
      { 'parentMeasurementID' => 'to_traits_parent_pk' },
      { 'measurementType' => 'to_traits_predicate', can_be_empty: false },
      { 'measurementValue' => 'to_traits_value' },
      { 'measurementUnit' => 'to_traits_units' },
      { 'measurementAccuracy' => 'to_traits_meta', submapping: 'http://rs.tdwg.org/dwc/terms/measurementAccuracy' },
      { 'statisticalMethod' => 'to_traits_statistical_method' },
      { 'measurementDeterminedDate' => 'to_traits_meta',
        submapping: 'http://rs.tdwg.org/dwc/terms/measurementDeterminedDate' },
      { 'measurementDeterminedBy' => 'to_traits_meta',
        submapping: 'http://rs.tdwg.org/dwc/terms/measurementDeterminedBy' },
      { 'measurementMethod' => 'to_traits_meta', submapping: 'http://rs.tdwg.org/dwc/terms/measurementMethod' },
      { 'measurementRemarks' => 'to_traits_meta', submapping: 'http://rs.tdwg.org/dwc/terms/measurementRemarks' },
      { 'source' => 'to_traits_source' },
      { 'bibliographicCitation' => 'to_traits_meta', submapping: 'http://purl.org/dc/terms/bibliographicCitation' },
      { 'contributor' => 'to_traits_meta', submapping: 'http://purl.org/dc/terms/contributor' },
      { 'referenceID' => 'to_ignored' }
    ] }
  }
)

Resource.quick_define(
  name: 'IUCN Structured Data',
  abbr: 'IUCN-SD',
  type: :csv,
  field_sep: "\t",
  pk_url: 'http://some.cool.url/with/a/path/to_$PK.html',
  base_dir: Rails.public_path.join('data', 'iucn'),
  partner: {
    name: 'International Union for Conservation of Nature',
    abbr: 'IUCN',
    short_name: 'IUCN',
    homepage_url: 'https://www.iucn.org/',
    description: 'The International Union for Conservation of Nature (IUCN) is a membership Union uniquely composed of both government and civil society organisations. It provides public, private and non-governmental organisations with the knowledge and tools that enable human progress, economic development and nature conservation to take place together.',
    auto_publish: true
  },
  formats: {
    nodes: { loc: 'taxon.tab', fields: [
      { 'taxonID' => 'to_nodes_pk', is_unique: true, can_be_empty: false },
      { 'furtherInformationURL' => 'to_ignored' },
      { 'scientificName' => 'to_nodes_scientific', can_be_empty: false },
      { 'kingdom' => 'to_nodes_ancestor', submapping: 'kingdom' },
      { 'phylum' => 'to_nodes_ancestor', submapping: 'phylum' },
      { 'class' => 'to_nodes_ancestor', submapping: 'class' },
      { 'order' => 'to_nodes_ancestor', submapping: 'order' },
      { 'family' => 'to_nodes_ancestor', submapping: 'family' }
    ] },
    occurrences: { loc: 'occurrence.tab', fields: [
      { 'occurrenceID' => 'to_occurrences_pk', can_be_empty: false, is_unique: true },
      { 'taxonID' => 'to_occurrences_nodes_fk', can_be_empty: false }
    ] },
    measurements: { loc: 'measurement_or_fact.tab', fields: [
      { 'occurrenceID' => 'to_traits_occurrence_fk' },
      { 'measurementOfTaxon' => 'to_traits_measurement_of_taxon' },
      { 'measurementType' => 'to_traits_predicate', can_be_empty: false },
      { 'measurementValue' => 'to_traits_value' },
      { 'measurementRemarks' => 'to_traits_meta', submapping: 'http://rs.tdwg.org/dwc/terms/measurementRemarks' },
      { 'source' => 'to_traits_source' }
    ] }
  }
)

Resource.quick_define(
  name: 'CalPhotos in DwC-A',
  abbr: 'CalPhotos',
  type: :csv,
  partner: {
    name: 'CalPhotos',
    abbr: 'CalPhotos',
    short_name: 'CalPhotos',
    homepage_url: 'http://calphotos.berkeley.edu/',
    description: 'CalPhotos is a collection of photos of plants, animals, fossils, people, and landscapes from around '\
      'the world. A variety of organizations and individuals have contributed photographs to...',
    auto_publish: true
  },
  field_sep: "\t",
  pk_url: '',
  base_dir: Rails.root.join('spec', 'files', 'calphotos'),
  formats: {
    nodes: { loc: 'taxa.tsv', fields: [
      { 'taxonID' => 'to_nodes_pk', is_unique: true, can_be_empty: false },
      { 'furtherInformationURL' => 'to_nodes_further_information_url' },
      { 'scientificName' => 'to_nodes_scientific' }
    ] },
    media: { loc: 'media.tsv', fields: [
      { 'identifier' => 'to_media_pk', is_unique: true, can_be_empty: false },
      { 'taxonID' => 'to_media_nodes_fk', can_be_empty: false },
      { 'type' => 'to_media_type', can_be_empty: false },
      { 'format' => 'to_media_subtype' },
      { 'description' => 'to_media_description' },
      { 'accessURI' => 'to_media_source_url' },
      { 'furtherInformationURL' => 'to_media_source_page_url' },
      { 'CreateDate' => 'to_ignored' },
      { 'UsageTerms' => 'to_media_license' },
      { 'Owner' => 'to_media_owner' },
      { 'LocationCreated' => 'to_media_locality' },
      { 'rights' => 'to_media_rights_statement' },
      { 'ReferenceID' => 'to_media_ref_fks', submapping: ',' }
    ] },
    refs: { loc: 'references.tsv', fields: [
      { 'ReferenceID' => 'to_refs_pk' },
      { 'PublicationType' => 'to_ignored' },
      { 'Full Reference' => 'to_refs_body' },
      { 'PrimaryTitle' => 'to_refs_part' },
      { 'SecondaryTitle' => 'to_refs_part' },
      { 'Pages' => 'to_refs_part' },
      { 'PageStart' => 'to_ignored' },
      { 'PageEnd' => 'to_ignored' },
      { 'VolumeEdition' => 'to_refs_part' }, # TODO: this looks like a bug; should be TWO fields. Oh well.
      { 'Publisher' => 'to_refs_part' },
      { 'AuthorList' => 'to_refs_part' },
      { 'EditorList' => 'to_refs_part' },
      { 'DateCreated' => 'to_refs_part' },
      { 'Language' => 'to_ignored' }, # TODO: should we handle this? I don't think we care about it.
      { 'URL' => 'to_refs_url' },
      { 'DOI' => 'to_refs_doi' },
      { 'LocalityOfPublisher' => 'to_refs_part' }
    ] }
  }
)

Resource.quick_define(
  name: 'Flickr BHL',
  abbr: 'flickrBHL',
  type: :csv,
  partner: {
    name: 'Flickr',
    abbr: 'flickr',
    short_name: 'Flickr',
    homepage_url: 'http://flickr.com/',
    description: 'Flickr - almost certainly the best online photo management and sharing application in the world',
    auto_publish: true
  },
  field_sep: "\t",
  pk_url: '',
  base_dir: Rails.public_path.join('data', 'flickr'),
  formats: {
    nodes: { loc: 'taxon.tab', fields: [
      { 'taxonID' => 'to_nodes_pk', is_unique: true, can_be_empty: false },
      { 'scientificName' => 'to_nodes_scientific' },
      { 'genus' => 'to_nodes_ancestor', submapping: 'genus' },
      { 'order' => 'to_nodes_ancestor', submapping: 'order' },
      { 'family' => 'to_nodes_ancestor', submapping: 'family' },
      { 'kingdom' => 'to_nodes_ancestor', submapping: 'kingdom' },
      { 'phylum' => 'to_nodes_ancestor', submapping: 'phylum' },
      { 'class' => 'to_nodes_ancestor', submapping: 'class' }
    ] },
    media: { loc: 'media_resource.tab', fields: [
      { 'identifier' => 'to_media_pk', is_unique: true, can_be_empty: false },
      { 'taxonID' => 'to_media_nodes_fk', can_be_empty: false },
      { 'type' => 'to_media_type', can_be_empty: false },
      { 'format' => 'to_media_subtype' },
      { 'title' => 'to_media_name' },
      { 'accessURI' => 'to_media_source_url' },
      { 'furtherInformationURL' => 'to_media_source_page_url' },
      { 'CreateDate' => 'to_ignored' },
      { 'language' => 'to_media_language' },
      { 'UsageTerms' => 'to_media_license' },
      { 'Owner' => 'to_media_owner' },
      { 'description' => 'to_media_description' },
      { 'additionalInformation' => 'to_ignored' } # NOTE: I *think* this is reasonable (we can't show it!)...
    ] },
    vernaculars: { loc: 'vernacular_name.tab', fields: [
      { 'vernacularName' => 'to_vernaculars_verbatim' },
      { 'language' => 'to_vernaculars_language', submapping: 'en' },
      { 'taxonID' => 'to_vernacular_nodes_fk' }
    ] }
  }
)

Resource.quick_define(
  name: 'Mammal Interactions Test Data',
  abbr: 'mam_inter',
  type: :csv,
  field_sep: ",",
  line_sep: "\r\n",
  pk_url: 'http://some.cool.url/with/a/path/to_$PK.html',
  base_dir: Rails.public_path.join('data', 'mam_inter'),
  partner: eol_attrs,
  formats: {
    nodes: { loc: 'taxa.csv', fields: [
      { 'taxonID' => 'to_nodes_pk', is_unique: true, can_be_empty: false },
      { 'scientificName' => 'to_nodes_scientific', can_be_empty: false },
      { 'parentNameUsageID' => 'to_nodes_parent_fk' },
      { 'kingdom' => 'to_nodes_ancestor', submapping: 'kingdom' },
      { 'phylum' => 'to_nodes_ancestor', submapping: 'phylum' },
      { 'class' => 'to_nodes_ancestor', submapping: 'class' },
      { 'order' => 'to_nodes_ancestor', submapping: 'order' },
      { 'family' => 'to_nodes_ancestor', submapping: 'family' },
      { 'genus' => 'to_nodes_ancestor', submapping: 'genus' },
      { 'taxonRank' => 'to_nodes_rank' },
      { 'furtherInformationURL' => 'to_nodes_further_information_url' }
    ] },
    occurrences: { loc: 'occurrence.csv', fields: [
      { 'occurrenceID' => 'to_occurrences_pk', can_be_empty: false, is_unique: true },
      { 'taxonID' => 'to_occurrences_nodes_fk', can_be_empty: false }
    ] },
    assocs: { loc: 'association.csv', fields: [
      { 'associationID' => 'to_associations_pk', is_unique: true, can_be_empty: false },
      { 'occurrenceID' => 'to_associations_occurrence_fk', can_be_empty: false },
      { 'associationType' => 'to_associations_predicate', can_be_empty: false },
      { 'targetOccurrenceID' => 'to_associations_target_occurrence_fk' },
      { 'measurementDeterminedDate' => 'to_associations_meta',
        submapping: 'http://rs.tdwg.org/dwc/terms/measurementDeterminedDate' },
      { 'measurementDeterminedBy' => 'to_associations_meta',
        submapping: 'http://rs.tdwg.org/dwc/terms/measurementDeterminedBy' },
      { 'measurementMethod' => 'to_associations_meta', submapping: 'http://rs.tdwg.org/dwc/terms/measurementMethod' },
      { 'measurementRemarks' => 'to_associations_meta', submapping: 'http://rs.tdwg.org/dwc/terms/measurementRemarks' },
      { 'source' => 'to_associations_source' },
      { 'bibliographicCitation' => 'to_associations_meta',
        submapping: 'http://purl.org/dc/terms/bibliographicCitation' },
      { 'contributor' => 'to_associations_meta', submapping: 'http://purl.org/dc/terms/contributor' },
      { 'referenceID' => 'to_associations_ref_fks', submapping: ';' }
    ] },
    refs: { loc: 'references.csv', fields: [
      { 'identifier' => 'to_refs_pk', is_unique: true, can_be_empty: false },
      { 'publicationType' => 'to_ignored' },
      { 'full_reference' => 'to_refs_body' },
      { 'primaryTitle' => 'to_ignored' },
      { 'title' => 'to_ignored' },
      { 'pages' => 'to_ignored' },
      { 'pageStart' => 'to_ignored' },
      { 'pageEnd' => 'to_ignored' },
      { 'volume' => 'to_ignored' },
      { 'edition' => 'to_ignored' },
      { 'publisher' => 'to_ignored' },
      { 'authorList' => 'to_ignored' },
      { 'editorList' => 'to_ignored' },
      { 'created' => 'to_ignored' },
      { 'language' => 'to_ignored' },
      { 'uri' => 'to_refs_url' },
      { 'doi' => 'to_refs_doi' },
      { 'schema#localityName' => 'to_ignored' }
    ] }
  }
)

Resource.quick_define(
  name: 'Carnivore Names Test',
  abbr: 'carn_names',
  type: :csv,
  partner: eol_attrs,
  field_sep: "\t",
  pk_url: 'http://eol.org/$PK&but=not_really',
  base_dir: Rails.root.join('spec', 'files', 'carn_names'),
  formats: {
    nodes: { loc: 'taxon.tab', fields: [
      { 'taxonID' => 'to_nodes_pk', is_unique: true, can_be_empty: false },
      { 'furtherInformationURL' => 'to_nodes_further_information_url' },
      { 'referenceID' => 'to_ignored' }, # unused in this resource.
      { 'parentNameUsageID' => 'to_nodes_parent_fk' },
      { 'scientificName' => 'to_nodes_scientific' },
      { 'namePublishedIn' => 'to_nodes_publication' },
      { 'kingdom' => 'to_nodes_ancestor', submapping: 'kingdom' },
      { 'phylum' => 'to_nodes_ancestor', submapping: 'phylum' },
      { 'class' => 'to_nodes_ancestor', submapping: 'class' },
      { 'order' => 'to_nodes_ancestor', submapping: 'order' },
      { 'family' => 'to_nodes_ancestor', submapping: 'family' },
      { 'genus' => 'to_nodes_ancestor', submapping: 'genus' },
      { 'taxonRank' => 'to_nodes_rank' },
      { 'taxonomicStatus' => 'to_taxonomic_status' },
      { 'taxonRemarks' => 'to_nodes_remarks' }
    ] },
    vernaculars: { loc: 'vernacular_name.tab', fields: [
      # vernacularName	source	language	locality	countryCode	isPreferredName	taxonRemarks	taxonID
      { 'vernacularName' => 'to_vernaculars_verbatim' },
      { 'source' => 'to_vernaculars_source' },
      { 'language' => 'to_vernaculars_language', submapping: 'en' },
      { 'locality' => 'to_vernaculars_locality' },
      { 'countryCode' => 'to_ignored' }, # ???
      { 'isPreferredName' => 'to_vernaculars_preferred' },
      { 'taxonRemarks' => 'to_vernaculars_remarks' },
      { 'taxonID' => 'to_vernacular_nodes_fk', can_be_empty: false }
    ] }
  }
)

Resource.quick_define(
  name: 'Carnivora Articles Test',
  abbr: 'carn_art',
  type: :csv,
  partner: eol_attrs,
  field_sep: "\t",
  pk_url: '',
  base_dir: Rails.public_path.join('data', 'carn_art'),
  formats: {
    nodes: { loc: 'taxon.tab', fields: [
      { 'taxonID' => 'to_nodes_pk', is_unique: true, can_be_empty: false },
      { 'furtherInformationURL' => 'to_nodes_further_information_url' },
      { 'scientificName' => 'to_nodes_scientific' },
      { 'kingdom' => 'to_nodes_ancestor', submapping: 'kingdom' },
      { 'phylum' => 'to_nodes_ancestor', submapping: 'phylum' },
      { 'class' => 'to_nodes_ancestor', submapping: 'class' },
      { 'order' => 'to_nodes_ancestor', submapping: 'order' },
      { 'family' => 'to_nodes_ancestor', submapping: 'family' },
      { 'referenceID' => 'to_nodes_ref_fks', submapping: ';' },
      { 'modified' => 'to_ignored' }
    ] },
    media: { loc: 'media_resource.tab', fields: [
      { 'identifier' => 'to_media_pk', is_unique: true, can_be_empty: false },
      { 'taxonID' => 'to_media_nodes_fk', can_be_empty: false },
      { 'type' => 'to_media_type', can_be_empty: false },
      { 'format' => 'to_media_subtype' },
      { 'CVterm' => 'to_section' },
      { 'title' => 'to_media_name' },
      { 'description' => 'to_media_description' },
      { 'accessURI' => 'to_media_source_url' },
      { 'thumbnailURL' => 'to_ignored' },
      { 'furtherInformationURL' => 'to_media_source_page_url' },
      { 'language' => 'to_media_language' },
      { 'audience' => 'to_ignored' },
      { 'UsageTerms' => 'to_media_license' },
      { 'rights' => 'to_media_rights_statement' },
      { 'Owner' => 'to_media_owner' },
      { 'LocationCreated' => 'to_media_locality' },
      { 'CreateDate' => 'to_ignored' },
      { 'modified' => 'to_ignored' },
      { 'bibliographicCitation' => 'to_bibliographic_citation' },
      { 'ReferenceID' => 'to_media_ref_fks', submapping: ',' }
    ] },
    refs: { loc: 'reference.tab', fields: [
      { 'identifier' => 'to_refs_pk', is_unique: true, can_be_empty: false },
      { 'full_reference' => 'to_refs_body' },
      { 'uri' => 'to_refs_url' }
    ] },
    vernaculars: { loc: 'vernacular_name.tab', fields: [
      { 'vernacularName' => 'to_vernaculars_verbatim', can_be_empty: false },
      { 'language' => 'to_vernaculars_language', submapping: 'en' },
      { 'taxonID' => 'to_vernacular_nodes_fk', can_be_empty: false }
    ] }
  }
)

Resource.quick_define(
  name: 'PanTHERIA',
  abbr: 'pantheria',
  type: :csv,
  partner: {
    name: 'PanTHERIA',
    abbr: 'pantheria',
    short_name: 'Pantheria',
    homepage_url: 'http://esapubs.org/archive/ecol/E090/184/',
    description: 'PanTHERIA is a species-level data set compiled for analysis of life history, ecology, and geography '\
      'of all known extant and recently extinct mammals.',
    auto_publish: false
  },
  field_sep: "\t",
  pk_url: '',
  base_dir: Rails.public_path.join('data', 'pantheria'),
  formats: {
    nodes: { loc: 'taxon.tab', fields: [
      { 'taxonID' => 'to_nodes_pk', is_unique: true, can_be_empty: false },
      { 'furtherInformationURL' => 'to_nodes_further_information_url' },
      { 'referenceID' => 'to_nodes_ref_fks', submapping: ';' },
      { 'parentNameUsageID' => 'to_nodes_parent_fk' },
      { 'scientificName' => 'to_nodes_scientific' },
      { 'namePublishedIn' => 'to_nodes_publication' },
      { 'kingdom' => 'to_nodes_ancestor', submapping: 'kingdom' },
      { 'phylum' => 'to_nodes_ancestor', submapping: 'phylum' },
      { 'class' => 'to_nodes_ancestor', submapping: 'class' },
      { 'order' => 'to_nodes_ancestor', submapping: 'order' },
      { 'family' => 'to_nodes_ancestor', submapping: 'family' },
      { 'genus' => 'to_nodes_ancestor', submapping: 'genus' },
      { 'taxonRank' => 'to_nodes_rank' },
      { 'taxonomicStatus' => 'to_taxonomic_status' },
      { 'taxonRemarks' => 'to_nodes_remarks' }
    ] },
    refs: { loc: 'reference.tab', fields: [
      { 'identifier' => 'to_refs_pk' },
      { 'publicationType' => 'to_ignored' },
      { 'full_reference' => 'to_refs_body' },
      { 'primaryTitle' => 'to_refs_part' },
      { 'title' => 'to_refs_part' },
      { 'pages' => 'to_refs_part' },
      { 'pageStart' => 'to_ignored' },
      { 'pageEnd' => 'to_ignored' },
      { 'volume' => 'to_refs_part' },
      { 'edition' => 'to_refs_part' },
      { 'publisher' => 'to_refs_part' },
      { 'authorList' => 'to_refs_part' },
      { 'editorList' => 'to_refs_part' },
      { 'created' => 'to_refs_part' },
      { 'language' => 'to_ignored' }, # TODO: should we handle this? I don't think we care about it.
      { 'uri' => 'to_refs_url' },
      { 'doi' => 'to_refs_doi' },
      { 'localityName' => 'to_refs_part' }
    ] },
    occurrences: { loc: 'occurrence.tab', fields: [
      { 'occurrenceID' => 'to_occurrences_pk', can_be_empty: false, is_unique: true },
      { 'taxonID' => 'to_occurrences_nodes_fk', can_be_empty: false },
      { 'eventID' => 'to_ignored' },
      { 'institutionCode' => 'to_ignored' },
      { 'collectionCode' => 'to_ignored' },
      { 'catalogNumber' => 'to_ignored' },
      { 'sex' => 'to_occurrences_sex' },
      { 'lifeStage' => 'to_occurrences_lifestage' },
      { 'reproductiveCondition' => 'to_occurrences_meta',
        submapping: 'http://rs.tdwg.org/dwc/terms/reproductiveCondition' },
      { 'behavior' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/behavior' },
      { 'establishmentMeans' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/establishmentMeans' },
      { 'occurrenceRemarks' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/occurrenceRemarks' },
      { 'individualCount' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/individualCount' },
      { 'preparations' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/preparations' },
      { 'fieldNotes' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/fieldNotes' },
      { 'samplingProtocol' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/samplingProtocol' },
      { 'samplingEffort' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/samplingEffort' },
      { 'recordedBy' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/recordedBy' },
      { 'identifiedBy' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/identifiedBy' },
      { 'dateIdentified' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/dateIdentified' },
      { 'eventDate' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/eventDate' },
      { 'modified' => 'to_occurrences_meta', submapping: 'http://purl.org/dc/terms/modified' },
      { 'locality' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/locality' },
      { 'decimalLatitude' => 'to_occurrences_lat' },
      { 'decimalLongitude' => 'to_occurrences_long' },
      { 'verbatimLatitude' => 'to_occurrences_lat_literal' },
      { 'verbatimLongitude' => 'to_occurrences_long_literal' },
      { 'verbatimElevation' => 'to_occurrences_meta', submapping: 'http://rs.tdwg.org/dwc/terms/verbatimElevation' }
    ] },
    measurements: { loc: 'measurement_or_fact.tab', fields: [
      { 'measurementID' => 'to_traits_pk', can_be_empty: false, is_unique: true },
      { 'occurrenceID' => 'to_traits_occurrence_fk' },
      { 'measurementOfTaxon' => 'to_traits_measurement_of_taxon' },
      { 'associationID' => 'to_traits_assoc_node_fk' },
      { 'parentMeasurementID' => 'to_traits_parent_pk' },
      { 'measurementType' => 'to_traits_predicate', can_be_empty: false },
      { 'measurementValue' => 'to_traits_value' },
      { 'measurementUnit' => 'to_traits_units' },
      { 'measurementAccuracy' => 'to_traits_meta', submapping: 'http://rs.tdwg.org/dwc/terms/measurementAccuracy' },
      { 'statisticalMethod' => 'to_traits_statistical_method' },
      { 'measurementDeterminedDate' => 'to_traits_meta',
        submapping: 'http://rs.tdwg.org/dwc/terms/measurementDeterminedDate' },
      { 'measurementDeterminedBy' => 'to_traits_meta',
        submapping: 'http://rs.tdwg.org/dwc/terms/measurementDeterminedBy' },
      { 'measurementMethod' => 'to_traits_meta', submapping: 'http://rs.tdwg.org/dwc/terms/measurementMethod' },
      { 'measurementRemarks' => 'to_traits_meta', submapping: 'http://rs.tdwg.org/dwc/terms/measurementRemarks' },
      { 'source' => 'to_traits_source' },
      { 'bibliographicCitation' => 'to_traits_meta', submapping: 'http://purl.org/dc/terms/bibliographicCitation' },
      { 'contributor' => 'to_traits_meta', submapping: 'http://purl.org/dc/terms/contributor' },
      { 'referenceID' => 'to_ignored' } # TODO: this one (and there's another in another resource) should be handled...
    ] }
  }
)

MetaXmlField.reimport

Node.reindex # This empties all of the stuff from ElasticSearch.

# Jonathan's thought: use a table to store ids. You could do something like
# create_table :keys_to_ids do |t|
#   t.integer :resource_id
#   t.string :their_key
#   t.string :our_type
#   t.integer :our_id
# end
#
# class KeyToId < ActiveRecord::Base
#   belongs_to :resource, inverse_of: :key_to_ids
#   belongs_to :our, polymorphic: true
# end
#
# # ...then when you harvest something with a PK or FK, you slurp in the known IDs:
# known_ids = {}
# KeyToId.where(resource_id: @resource.id, our_type: klass.name).find_each { |kti| known_ids[kti.their_key] = kti.our_id }
# YOU WERE HERE
