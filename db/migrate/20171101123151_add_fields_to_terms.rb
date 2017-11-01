# 20171101123151
class AddFieldsToTerms < ActiveRecord::Migration
  def change
    add_column :terms, :ontology_information_url, :text
    add_column :terms, :ontology_source_url, :text
    add_column :terms, :is_text_only, :boolean
    add_column :terms, :is_verbatim_only, :boolean
    add_column :terms, :position, :integer
    add_column :terms, :used_for, :integer, comment: 'enum: '
  end
end
