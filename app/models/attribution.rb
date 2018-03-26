# AKA an "agent" ... this is a person or organization that receives credit for some content. I apologize for changing
# the name, but, as represented (with a role attached), these really are *attributions*, not "agents". Someday perhaps
# we'll abstract the two, but not now.
class Attribution < ActiveRecord::Base
  has_many :content_attributions, inverse_of: :attribution

  # TODO: this is lame. Just publish agents and store them over there, so we can render them properly.
  def body
    parts = []
    parts <<
      if !name.blank?
        if url.blank?
          name
        else
          "<a href='#{sanitize_url}'>#{name}</a>"
        end
      elsif !url.blank?
        "[<a href='#{sanitize_url}'>website</a>]"
      end
    parts << "[<a href='mailto:#{sanitize_email}'>email</a>]" if email
    parts.join(' ')
  end

  def sanitize_url
    @sanitize_url ||= URI.escape(URI.unescape(url))
  end

  def sanitize_email
    @sanitize_email ||= email[/[^@\s]+@([^@\s]+\.)+[^@\s]+/]
  end
end
