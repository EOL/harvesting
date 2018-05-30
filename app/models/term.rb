class Term < ActiveRecord::Base
  enum used_for: %i[unknown measurement association value metadata]

  def self.uri?(uri)
    return false if uri.nil?
    return false unless uri.respond_to?(:=~) # String-ish duck type
    @valid_protocols ||= %w[http doi].join('|')
    return false unless (uri =~ URI::ABS_URI)&.zero? # NOTE: must be at the start
    return false unless uri =~ /^(#{@valid_protocols})/i
    true
  end

  def self.add_new_terms
    Term.from_file(Rails.root.join('doc', 'new_terms.json'))
  end

  def self.from_file(terms_file, options = {})
    unless File.exist?(terms_file)
      puts("No terms file found (#{terms_file}), skipping. #{'Your term URIs will not be defined.' if options[:flush]}")
      return
    end
    Term.delete_all if options[:flush]
    puts '.. Importing terms'
    json = JSON.parse(File.read(terms_file))
    Term.from_json(json)
  end

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
    Rails.cache.clear
    terms
  end
end
