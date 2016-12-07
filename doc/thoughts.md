## Name Changes

taxon_concept => page
hierarchy_entry => node
data_object => "media" -> "image", "map", "article"

## Process

The "normalization" process is where we should apply any formatting/field
changes. The Diff process shouldn't change anything, just find diffs!

## Resource File Changes

The "agents" data is ignored, now. We never did anything with it.

"Events" were always ignored, and will continue to be. Half-baked idea.

### Media

We're not going to do type/subtype. Just type.

We're ignoring format. We never use it.

We're ignoring thumbnail_url. We never use it.

We'll get all of the URLs and contributor info separately, but when we pass it
to the website, we'll want to build compact source_info_json out of it
(source_info). source_info_json will include location and spatial location.

### Names

locality and countrycode are ignored. They always were. Lame.

taxonRemarks was stored, but never made it anywhere. Ignoring it (for now).

source was, surprisingly, ignored. So I'm ignoring it, too.

### File Format

Yes, I'm flushing everything left, just to save a few chars.
