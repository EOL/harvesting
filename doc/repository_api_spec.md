# Repository API Specification

First draft, created Mar 2019, is just meant as a loose list of the kinds of queries that will be needed, not a
full-fledged list of functions, their parameters, and the expected return values.

## "Obvious" functionality

- Writing new records to the database (preferably in bulk)
- Querying a class by resource_id and getting all results (probably in pages of variable size)
- Querying a single instance by resource_id and resource_pk
- Updating instances by resource_id and resource_pk, setting a variable set of fields/values.
- Getting simple counts based on queries (see below), rather than the results

## Methods

### resolve_keys

- find nodes that have parent_resource_pk values that do NOT have a matching resource_pk
- find scientific_names that have node_resource_pk values that do NOT have a matching nodes.resource_pk
- find vernaculars that have node_resource_pk values that do NOT have a matching nodes.resource_pk
- find identifiers that have node_resource_pk values that do NOT have a matching nodes.resource_pk
- find media that have node_resource_pk values that do NOT have a matching nodes.resource_pk
- find articles that have node_resource_pk values that do NOT have a matching nodes.resource_pk
- find articles that have section values that do NOT have a matching section
- find occurrences that have node_resource_pk values that do NOT have a matching nodes.resource_pk
- find traits that have occurrence ID values that do NOT have a matching occurrence.resource_pk
- find associations that have occurrence ID values that do NOT have a matching occurrence.resource_pk
- find attributions that have node_resource_pk values that do NOT have a matching nodes.resource_pk
- find ALL reference IDs (on all classes) that do NOT have a matching references.resource_pk
- find ALL bibliographic citation IDs (on all classes) that do NOT have a matching bibliographic_citations.resource_pk
- find ALL attribution IDs (on all classes) that do NOT have a matching attributions.resource_pk

There's some question about how we want to handle the rows identified by these results. IDEALLY, we would be able to
flag them and skip them from harvest, but that *could* get complicated as relationships can be nested. Warrants
discussion.

## Other queries

These are part of the harvesting process but didn't fall neatly into a function (because we need to compute things on
the results).

- Node.where(resource_id: @resource.id).published.pluck_in_batches(:id, :parent_id)
- ScientificName.where(harvest_id: @harvest.id, canonical: nil)
- Trait.where(harvest_id: @harvest.id).where('measurement IS NOT NULL AND units_term_id IS NOT NULL')

## The publishing dataset

@meta_heads = %i[eol_pk trait_eol_pk predicate literal measurement value_uri units sex lifestage
                 statistical_method source]
@same_sci_name_attributes =
 %i[italicized genus specific_epithet infraspecific_epithet infrageneric_epithet uninomial verbatim
    authorship publication remarks parse_quality year hybrid surrogate virus]

@same_article_attributes = %i[guid resource_pk source_url name body source_url]
@same_medium_attributes =
  %i[guid resource_pk source_url name description unmodified_url base_url
     source_page_url rights_statement usage_statement]
@same_node_attributes = %i[page_id parent_resource_pk in_unmapped_area resource_pk source_url]
@same_vernacular_attributes = %i[node_resource_pk locality remarks source]

### The big query
@nodes = @resource.nodes.published
                  .includes(:identifiers, :node_ancestors, :references,
                            vernaculars: [:language], scientific_names: [:dataset, :references],
                            media: %i[node license language references bibliographic_citation location] <<
                              { content_attributions: :attribution },
                            articles: %i[node license language references bibliographic_citation location
                                         articles_sections] <<
                              { content_attributions: :attribution })

### Classes

You might need to add references (and the like) to these.

#### Vernaculars

web_vern = Struct::WebVernacular.new
web_vern.node_id = node.id # NOTE: this is a HARV DB ID. We will convert it later.
web_vern.page_id = node.page_id
web_vern.harv_db_id = vernacular.id
web_vern.resource_id = @web_resource_id
web_vern.language_id = WebDb.language(vernacular.language, @logger)
web_vern.created_at = Time.now.to_s(:db)
web_vern.updated_at = Time.now.to_s(:db)
web_vern.is_preferred = 0 # This will be fixed by the code mentioned above, run on the website.
web_vern.trust = 0
web_vern.is_preferred_by_resource = clean_values(vernacular.is_preferred || false)
web_vern.string = clean_values(vernacular.verbatim)

#### Nodes

web_node = Struct::WebNode.new
copy_fields(@same_node_attributes, node, web_node)
web_node.resource_id = @web_resource_id
web_node.parent_id = node.parent_id # NOTE this is a HARV DB ID. We need to update it.
web_node.harv_db_id = node.id
web_node.canonical_form = clean_values(node.safe_canonical)
web_node.scientific_name = clean_values(node.safe_scientific)
web_node.has_breadcrumb = clean_values(!node.no_landmark?)
web_node.rank_id = WebDb.rank(node.rank, @logger)
web_node.is_hidden = 0
web_node.created_at = Time.now.to_s(:db)
web_node.updated_at = Time.now.to_s(:db)
web_node.landmark = Node.landmarks[node.landmark] # NOTE: we are RELYING on the enum being the same, here!

#### Attributions

attribution = Struct::WebAttribution.new
attribution.value = clean_values(content_attribution.attribution.body)
attribution.created_at = t
attribution.updated_at = t
attribution.resource_id = @web_resource_id
attribution.resource_pk = content_attribution.attribution.resource_pk
attribution.content_resource_fk = content_attribution.content_resource_fk
attribution.content_type = content_attribution.content_type
attribution.content_id = content_attribution.content_id # NOTE this is the HARVEST DB ID. It will be replaced.
attribution.role_id = WebDb.role(content_attribution.attribution.role, @logger)
attribution.url = content_attribution.attribution.sanitize_url

#### Sections (TOC Items)

section = Struct::WebContentSection.new
section.resource_id = @web_resource_id
section.content_id = object.id # NOTE this is the HARVEST DB ID. It will be replaced.
section.content_type = type
section.section_id = articles_section.section_id # WE ASSUME THE IDs ARE THE SAME! (q.v.: DefaultSections)

#### Bibliographic Citations

bc = Struct::WebBibliographicCitation.new
bc.body = clean_values(citation.body)
bc.created_at = t
bc.updated_at = t
bc.harv_db_id = citation.id
bc.resource_id = @web_resource_id

#### Locations

loc_struct = Struct::WebLocation.new
loc_struct.location = literal
loc_struct.longitude = loc.long
loc_struct.latitude = loc.lat
loc_struct.altitude = loc.alt
loc_struct.spatial_location = loc.locality
loc_struct.resource_id = @web_resource_id

#### Pages

New pages:

@pages[node.page_id] = Struct::WebPage.new
@pages[node.page_id].id = node.page_id
t = Time.now.to_s(:db)
@pages[node.page_id].created_at = t
@pages[node.page_id].updated_at = t
@pages[node.page_id].articles_count = node.articles.size
@pages[node.page_id].nodes_count = 1 # This one, silly!
@pages[node.page_id].vernaculars_count = node.vernaculars.size
@pages[node.page_id].scientific_names_count = node.scientific_names.size
@pages[node.page_id].articles_count = node.articles.size
@pages[node.page_id].referents_count = node.references.size
@pages[node.page_id].links_count = [some calc]
@pages[node.page_id].maps_count = [some calc]
@pages[node.page_id].page_contents_count = 0
@pages[node.page_id].species_count = 0
@pages[node.page_id].is_extinct = 0
@pages[node.page_id].is_marine = 0
@pages[node.page_id].has_checked_extinct = 0
@pages[node.page_id].has_checked_marine = 0

# Existing pages:

@pages[node.page_id].nodes_count ||= 0
@pages[node.page_id].media_count ||= 0
@pages[node.page_id].articles_count ||= 0
@pages[node.page_id].vernaculars_count ||= 0
@pages[node.page_id].scientific_names_count ||= 0
@pages[node.page_id].referents_count ||= 0
@pages[node.page_id].nodes_count += 1
@pages[node.page_id].media_count += node.media.size
@pages[node.page_id].articles_count += node.articles.size
@pages[node.page_id].vernaculars_count += node.vernaculars.size
@pages[node.page_id].scientific_names_count += node.scientific_names.size
@pages[node.page_id].referents_count += node.references.size

#### Identifiers

web_id = Struct::WebIdentifier.new
web_id.resource_id = @web_resource_id
web_id.harv_db_id = ider.id
web_id.node_resource_pk = node.resource_pk
web_id.node_id = ider.node_id # NOTE: this is a HARV DB ID. We will convert it later.
web_id.identifier = ider.identifier

#### Node Ancestors

Note that, again, I think these probably live in the MySQL database.

anc = Struct::WebNodeAncestor.new
anc.resource_id = @web_resource_id
anc.harv_db_id = nodan.id # TODO: I'm not sure this is required?
anc.node_id = nodan.node_id # NOTE: this is a HARV DB ID. We will convert it later.
anc.ancestor_id = nodan.ancestor_id # NOTE: this is a HARV DB ID. We will convert it later.
anc.node_resource_pk = node.resource_pk
anc.ancestor_resource_pk = nodan.ancestor_fk
anc.depth = nodan.depth

#### Scientific Names

name_struct = Struct::WebScientificName.new
name_struct.node_id = node.id # NOTE: this is a HARV DB ID. We will convert it later.
name_struct.page_id = node.page_id
name_struct.harv_db_id = name_model.id
name_struct.canonical_form = clean_values(name_model.canonical_italicized)
name_struct.taxonomic_status_id = WebDb.taxonomic_status(name_model.taxonomic_status.try(:downcase), @logger)
name_struct.is_preferred = clean_values(node.scientific_name_id == name_model.id)
name_struct.created_at = Time.now.to_s(:db)
name_struct.updated_at = Time.now.to_s(:db)
name_struct.resource_id = @web_resource_id
name_struct.node_resource_pk = clean_values(node.resource_pk)
name_struct.attribution = clean_values(name_model.attribution_html)

#### Articles

add_refs(article)
add_attributions(article)
add_sections(article, 'Article')
add_bib_cit(web_article, article.bibliographic_citation)
add_loc(web_article, article.location)

web_article = Struct::WebArticle.new
web_article.page_id = node.page_id
web_article.harv_db_id = article.id
web_article.owner = article.owner
copy_fields(@same_article_attributes, article, web_article)
web_article.created_at = Time.now.to_s(:db)
web_article.updated_at = Time.now.to_s(:db)
web_article.resource_id = @web_resource_id
web_article.license_id = WebDb.license(article.license&.source_url, @logger)
web_article.language_id = WebDb.language(article.language, @logger)

#### Media

add_refs(medium)
add_attributions(medium)
add_bib_cit(web_medium, medium.bibliographic_citation)
add_loc(web_medium, medium.location)
@image_info_by_node_pk[node.resource_pk] << build_image_info(medium) # ...If you're an image...

web_medium = Struct::WebMedium.new
web_medium.page_id = node.page_id
web_medium.harv_db_id = medium.id
web_medium.subclass = Medium.subclasses[medium.subclass]
web_medium.format = Medium.formats[medium.format]
web_medium.owner = medium.owner
# TODO: ImageInfo from medium.sizes
copy_fields(@same_medium_attributes, medium, web_medium)
web_medium.created_at = Time.now.to_s(:db)
web_medium.updated_at = Time.now.to_s(:db)
web_medium.resource_id = @web_resource_id
web_medium.name = clean_values(medium.name_verbatim) if medium.name.blank?
web_medium.description = clean_values(medium.description_verbatim) if medium.description.blank?
web_medium.base_url = if medium.base_url.nil? # The image has not been downloaded.
                        "#{@root_url}/#{medium.default_base_url}"
                      else
                        # It *has* been downloaded, but still lacks the root URL, so we add that:
                        "#{@root_url}/#{medium.base_url}"
                      end
web_medium.license_id = WebDb.license(medium.license&.source_url, @logger)
web_medium.language_id = WebDb.language(medium.language, @logger)

### Adding references

referent = Struct::WebReferent.new
referent.body = clean_values(ref.body)
referent.created_at = t
referent.updated_at = t
referent.resource_id = @web_resource_id
referent.harv_db_id = ref.id
@referents[ref.id] = referent
reference = Struct::WebReference.new
reference.parent_type = object.class.name
reference.parent_id = object.id # NOTE: this is a HARV DB ID and should be replaced later.
reference.resource_id = @web_resource_id
reference.referent_id = ref.id # NOTE: this is also a harv ID, and will need to be replaced.
@references << reference

#### Image Info

ii = Struct::WebImageInfo.new
ii.resource_id = @web_resource_id
ii.medium_id = medium.id # NOTE this is a HARV DB ID, and needs to be replaced.
ii.original_size = "#{medium.w}x#{medium.h}" if medium.w && medium.h
unless medium.sizes.blank?
  # e.g.: {"88x88"=>"88x88", "98x68"=>"98x65", "580x360"=>"540x360", "130x130"=>"130x130", "260x190"=>"260x173"}
  sizes = JSON.parse(medium.sizes)
  ii.large_size = sizes['580x360']
  ii.medium_size = sizes['260x190']
  ii.small_size = sizes['98x68']
end
ii.crop_x = medium.crop_x_pct
ii.crop_y = medium.crop_y_pct
ii.crop_w = medium.crop_w_pct
t = Time.now.to_s(:db)
ii.created_at = t
ii.updated_at = t
ii.resource_pk = medium.resource_pk

#### Traits

...note that V3 currently breaks up traits more than BA has been proposing for the repository DB, so this may require more work to get "right:"

Trait.primary.published.matched.where(node_id: nodes.map(&:id))
     .includes(property_fields,
               children: meta_fields,
               occurrence: { occurrence_metadata: meta_fields },
               node: :scientific_name,
               meta_traits: meta_fields)

Assoc.published.where(node_id: nodes.map(&:id))
    .includes(:predicate_term, :sex_term, :lifestage_term, :references,
              occurrence: { occurrence_metadata: meta_fields },
              node: :scientific_name, target_node: :scientific_name,
              meta_assocs: assoc_meta_fields)

@trait_heads = %i[eol_pk page_id scientific_name resource_pk predicate sex lifestage statistical_method source
                  object_page_id target_scientific_name value_uri literal measurement units normal_measurement
                  normal_units_uri]

#### Metadata

[ "#{meta.class.name}-#{meta.id}",
  trait.eol_pk,
  predicate,
  literal,
  meta.respond_to?(:measurement) ? meta.measurement : nil,
  meta.respond_to?(:object_term) ? meta.object_term&.uri : nil,
  meta.respond_to?(:units_term) ? meta.units_term&.uri : nil,
  meta.respond_to?(:sex_term) ? meta.sex_term&.uri : nil,
  meta.respond_to?(:lifestage_term) ? meta.lifestage_term&.uri : nil,
  meta.respond_to?(:statistical_method_term) ? meta.statistical_method_term&.uri : nil,
  meta.respond_to?(:source) ? meta.source : nil
]

## Notes

First: I think we need to talk about versioning for Nodes. The V3 code is written to account for "published" nodes and
retains copies of deleted nodes and the queries all handle a ".published" scope as a result. I'm not sure we can skip
that.

- Skipping flattening hierarchy, because that's a calculated process and is probably more natural to store in MySQL.
- Skipping names matching, because that only *reads* the flattened hierarchies (and the ES index). It *writes* to the repository, but that's covered by the "obvious queries."
- Skipping the building of the ES index, because I *think* we want to keep that. It's really mostly based on flattened hierarchies.
