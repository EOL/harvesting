json.total_pages @names.total_pages
json.current_page @names.current_page
json.scientific_names @names do |name|
  json.page_id name.node.page_id
  json.node_resource_pk name.node_resource_pk

  ital = name.normalized || name.verbatim
  canon = name.canonical || name.verbatim
  # TODO: infraspecies epithets should also be italicized.
  if name.normalized && name.genus && name.specific_epithet
    # TODO: make a helper. ...Also, we should probably store these in the db, I think...
    ital = name.normalized.sub(name.genus, "<i>#{name.genus}</i>")
      .sub(name.specific_epithet, "<i>#{name.specific_epithet}</i>")
    canon = canon.sub(name.genus, "<i>#{name.genus}</i>")
      .sub(name.specific_epithet, "<i>#{name.specific_epithet}</i>")
  end

  json.italicized ital
  json.canonical_form canon
  json.is_preferred name.node.scientific_name_id == name.id # TODO: make primary field? Note sure.
  json.taxonomic_status name.taxonomic_status.try(:downcase)
  json.extract! name, *%i(source_reference genus specific_epithet infraspecific_epithet infrageneric_epithet uninomial verbatim authorship publication remarks year hybrid surrogate virus parse_quality)
end
