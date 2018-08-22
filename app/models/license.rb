class License < ActiveRecord::Base
  has_many :resources, inverse_of: :license
  has_many :media, inverse_of: :license
  has_many :articles, inverse_of: :license

  class << self
    def public_domain
      Rails.cache.fetch("harvest/licenses/public_domain") do
        License.where(name: "public domain").first_or_create do |l|
          l.name = "public domain"
          l.source_url = "https://creativecommons.org/publicdomain/"
          l.icon_url = "https://i.creativecommons.org/p/mark/1.0/88x31.png"
          l.can_be_chosen_by_partners = true
        end
      end
    end
  end
end
