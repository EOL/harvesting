json.name @resource.name
json.abbr @resource.abbr
json.pk_url @resource.pk_url

# TODO: right now we're just force-feeding them everything as "new"; we'll handle deltas later. Harder problem!
json.nodes do
  json.new @nodes.count
end
json.scientific_names do
  json.new @scientific_names.count
end
json.vernaculars do
  json.new @vernaculars.count
end
json.media do
  json.new @media.count
end
json.traits do
  json.new @traits.count
end
