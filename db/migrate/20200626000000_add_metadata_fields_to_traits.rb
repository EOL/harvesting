class AddMetadataFieldsToTraits < ActiveRecord::Migration[4.2]
  # Boy, I really hate to have to add these all as text types, but ... I cannot guarantee that they are any smaller. :|
  add_column :traits, :sample_size, :text, comment: 'http://eol.org/schema/terms/SampleSize'
  add_column :traits, :citation, :text, comment: 'http://purl.org/dc/terms/bibliographicCitation'
  add_column :traits, :source, :text, comment: 'http://purl.org/dc/terms/source'
  add_column :traits, :remarks, :text, comment: 'http://rs.tdwg.org/dwc/terms/measurementRemarks'
  add_column :traits, :method, :text, comment: 'http://rs.tdwg.org/dwc/terms/measurementMethod'
end
