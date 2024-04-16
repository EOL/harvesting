json.name @resource.name
json.abbr @resource.abbr
json.pk_url @resource.pk_url
json.can_perform_trait_diffs @resource.can_perform_trait_diffs

# TODO: right now we're just force-feeding them everything as "new"; we'll handle deltas later. Harder problem!
json.nodes do
  json.new @resource.nodes.count
end
json.scientific_names do
  json.new @resource.scientific_names.count
end
json.vernaculars do
  json.new @resource.vernaculars.count
end
json.media do
  json.new @resource.media.count
end
json.traits do
  json.new @resource.traits.count
end
