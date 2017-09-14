json.site_pk @resource.site_pk
json.name @resource.name
json.abbr @resource.abbr
json.pk_url @resource.pk_url

# TODO: right now we're just force-feeding them everything as "new"; we'll handle deltas later. Harder problem!
json.nodes do
  json.new @resource.nodes.published.count
end
json.scientific_names do
  json.new @resource.scientific_names.published.count
end
json.vernaculars do
  json.new @resource.vernaculars.published.count
end
json.media do
  json.new @resource.media.published.count
end
json.traits do
  json.new @resource.traits.published.count
end
