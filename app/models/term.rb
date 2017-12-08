class Term < ActiveRecord::Base
  enum used_for: %i[unknown measurement association value metadata]

  def self.from_json(json)
    terms = []
    json.each do |u|
      u['used_for'] = u.delete('type')
      u.delete('hide_from_gui') # unused
      u['is_hidden_from_overview'] = u.delete('exclude_from_exemplars')
      u['is_hidden_from_glossary'] = u.delete('hide_from_glossary')
      u['is_text_only'] = u.delete('value_is_text')
      u['is_verbatim_only'] = u.delete('value_is_verbatim')
      terms << u
    end
    terms.in_groups_of(2000, false) do |group|
      Term.import(group)
    end
    terms
  end

end
