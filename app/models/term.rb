class Term < ActiveRecord::Base
  enum used_for: %i[unknown measurement association value metadata]

  def self.from_json(json)
    terms = []
    existing_terms = {}
    # NOTE: I'm not terribly worried about performance for this:
    Term.find_each { |t| existing_terms[t.uri] = t.id }
    json.each do |u|
      u['used_for'] = u.delete('type')
      u.delete('hide_from_gui') # unused
      u['is_hidden_from_overview'] = u.delete('exclude_from_exemplars')
      u['is_hidden_from_glossary'] = u.delete('hide_from_glossary')
      u['is_text_only'] = u.delete('value_is_text')
      u['is_verbatim_only'] = u.delete('value_is_verbatim')
      u['id'] = existing_terms[u['uri']] if existing_terms.key?(u['uri']) # Will update
      terms << u
    end
    terms.in_groups_of(2000, false) do |group|
      Term.import(
        group,
        on_duplicate_key_update: %i[uri name definition comment attribution is_hidden_from_glossary
                                    is_hidden_from_overview ontology_information_url ontology_source_url is_text_only
                                    is_verbatim_only position used_for]
      )
    end
    terms
  end
end
