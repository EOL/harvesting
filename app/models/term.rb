class Term < ApplicationRecord
  establish_connection Rails.env.to_sym
  enum used_for: %i[unknown measurement association value metadata]

  def self.uri?(uri)
    return false if uri.nil?
    return false unless uri.respond_to?(:=~) # String-ish duck type
    @valid_protocols ||= %w[http doi].join('|')
    return false unless (uri =~ URI::ABS_URI)&.zero? # NOTE: must be at the start
    return false unless uri =~ /^(#{@valid_protocols})/i
    true
  end
end
