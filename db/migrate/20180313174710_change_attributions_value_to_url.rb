class ChangeAttributionsValueToUrl < ActiveRecord::Migration[4.2]
  def change
    remove_column :attributions, :value # What was this?!
    url_limit = 2_083 # This is the max. size of a URL, according to teh Googs. Weird number.
    add_column :attributions, :url, :string, limit: url_limit
    change_column :articles, :source_url, :string, limit: url_limit
    change_column :licenses, :source_url, :string, limit: url_limit
    change_column :licenses, :icon_url, :string, limit: url_limit
    change_column :links, :source_url, :string, limit: url_limit
    change_column :media, :unmodified_url, :string, limit: url_limit
    change_column :media, :source_page_url, :string, limit: url_limit
    change_column :media, :source_url, :string, limit: url_limit
    change_column :media, :base_url, :string, limit: url_limit
    change_column :nodes, :further_information_url, :string, limit: url_limit
    change_column :partners, :homepage_url, :string, limit: url_limit
    change_column :references, :url, :string, limit: url_limit
    change_column :resources, :pk_url, :string, limit: url_limit
    change_column :resources, :opendata_url, :string, limit: url_limit
    change_column :terms, :ontology_information_url, :string, limit: url_limit
  end
end
