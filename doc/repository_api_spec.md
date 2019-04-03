# Repository API Specification

First draft, created Mar 2019, is just meant as a loose list of the kinds of queries that will be needed, not a
full-fledged list of functions, their parameters, and the expected return values.

## Basic functionality

- Writing new records to the database (preferably in bulk)
- Querying a class by resource_id and getting all results (probably in pages of variable size)
- Querying a single instance by resource_id and resource_pk
- Updating instances by resource_id and resource_pk, setting a variable set of fields/values.
- Getting simple counts based on queries (see below), rather than the results

### Important Queries

- Scientific Names where canonical is nil
- Traits that have a measurement with units; i.e.: where measurement IS NOT NULL AND units_term_id IS NOT NULL

## Referential Integrity

The following referential integrity must be preserved; rows that fail one of these tests should be ignored, and added to
a list of "warnings" for the harvest that an admin or master curator can read and address.

- nodes that have parent_resource_pk values that do NOT have a matching resource_pk
- scientific_names that have node_resource_pk values that do NOT have a matching nodes.resource_pk
- vernaculars that have node_resource_pk values that do NOT have a matching nodes.resource_pk
- identifiers that have node_resource_pk values that do NOT have a matching nodes.resource_pk
- media that have node_resource_pk values that do NOT have a matching nodes.resource_pk
- articles that have node_resource_pk values that do NOT have a matching nodes.resource_pk
- articles that have section values that do NOT have a matching section
- occurrences that have node_resource_pk values that do NOT have a matching nodes.resource_pk
- traits that have occurrence ID values that do NOT have a matching occurrence.resource_pk
- associations that have occurrence ID values that do NOT have a matching occurrence.resource_pk
- attributions that have node_resource_pk values that do NOT have a matching nodes.resource_pk
- ALL reference IDs (on all classes) that do NOT have a matching references.resource_pk
- ALL bibliographic citation IDs (on all classes) that do NOT have a matching bibliographic_citations.resource_pk
- ALL attribution IDs (on all classes) that do NOT have a matching attributions.resource_pk

## The publishing dataset classes

### Vernaculars

- node_id
- page_id
- resource_id
- language_id
- is_preferred
- string
- node_resource_pk
- locality
- remarks
- source

### Nodes

- page_id
- parent_resource_pk
- in_unmapped_area
- resource_pk
- source_url (this is calculated from the node's PK and the *resource's* "pk_url" attribute, q.v.: Node#source_url)
- canonical_form
- scientific_name (really this is the italicized version of the scientific name)
- has_breadcrumb
- rank
- landmark

### Attributions

- value
- resource_pk
- content_resource_fk (The id of the content to which the attribution is attached)
- content_type
- role
- url

### Bibliographic Citations

- body

### Locations

- location
- longitude
- latitude
- altitude
- spatial_location

### Pages

I'm assuming that only "new" pages (created by this resource) matters here.

- id
- articles_count
- nodes_count
- vernaculars_count
- scientific_names_count
- media_count
- articles_count
- referents_count
- links_count (unimplemented)
- maps_count
- page_contents_count (effectively a sum of media, articles, links, and maps)

### Identifiers

- node_resource_pk
- identifier

### Node Ancestors

Note that, again, I think these probably live in the MySQL database.

- node_resource_pk
- ancestor_resource_pk
- depth

### Scientific Names

- page_id
- canonical_form
- remarks
- verbatim
- taxonomic_status
- is_preferred
- node_resource_pk
- attribution

The following fields are populated by the global names parser process:

- italicized
- genus
- specific_epithet
- infraspecific_epithet
- infrageneric_epithet
- uninomial
- authorship
- publication
- parse_quality
- year
- hybrid
- surrogate
- virus

### Articles

- page_id
- owner
- guid
- resource_pk
- source_url
- name
- body
- license
- language

### Media

- page_id
- subclass
- format
- owner
- guid
- resource_pk
- source_url
- name
- description
- unmodified_url
- base_url
- source_page_url
- rights_statement
- usage_statement
- name
- description
- base_url
- license
- language

### Adding references

- some kind of identifier
- body

### Adding referents

- some kind of reference identifier (see above)
- parent_type
- parent_id
- referent_id

### Image Info

- resource_pk
- w
- h
- downloaded_at
- unmodified_url
- base_url
- original_size
- large_size = sizes['580x360']
- medium_size = sizes['260x190']
- small_size = sizes['98x68']
- crop_x = medium.crop_x_pct
- crop_y = medium.crop_y_pct
- crop_w = medium.crop_w_pct

### Traits

...note that V3 currently breaks up traits more than BA has been proposing for the repository DB, so this may require more work to get "right:"

- eol_pk page_id
- scientific_name
- resource_pk
- predicate
- sex
- lifestage
- statistical_method
- source
- object_page_id
- target_scientific_name
- value_uri
- literal
- measurement
- units
- normal_measurement
- normal_units_uri

### Metadata

- eol_pk
- trait_eol_pk
- predicate
- literal
- measurement
- value_uri
- units
- sex
- lifestage
- statistical_method
- source
- (a unique identifier of ANY kind)
- trait.eol_pk
- predicate
- literal
- measurement
- object_term
- units_term
- sex_term
- lifestage_term
- statistical_method_term
- source

## Notes

- Skipping flattening hierarchy, because that's a calculated process and is probably more natural to store in MySQL.
- Skipping the building of the ElasticSearch index, because I *think* we want to keep that in ES. It's really mostly based on flattened hierarchies.
- Skipping names matching, because that only *reads* the flattened hierarchies (and the ES index). It *writes* to the repository, but that's covered by the "obvious queries."
