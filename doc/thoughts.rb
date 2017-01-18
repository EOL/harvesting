# Skip ahead for the local code.

# From the website (i.e.: Not actually in this codebase, but I need to think
# about it):

# The website would periodically request harvests from the repository:
repository = RepositoryApi.new
per_page = 1000
deltas = {}
types = [:pages, :nodes, :scientific_names, :media, :etc]
actions = [:new, :changed, :removed]
# TODO: first we need to communicate which resources are available, so we get new resources,
resources = repository.diffs_since?(RepositorySync.last.created_at)
resources.each do |resource|
  repository.resource_diffs_since?(resource, RepositorySync.last.created_at).each do |diff|
    types.each do |type|
      actions.each do |action|
        next unless diff[type][action] &&
                    diff[type][action].to_i > 0
        page = 1
        have = 0
        while have < diff[type][action]
          response = repository.get_diff_deltas(resource_id: resource.id,
            since: RepositorySync.last.created_at, type: type, action: action,
            page: page, per_page: per_page)
          # TODO: error-handling
          deltas[type][action] += response[type]
          have += response.size
          page += 1
          last if response[:no_more_items]
        end
      end
    end
  end
  types.each do |type|
    actions.each do |action|
      # I didn't sketch out these actions. Some of them would be moderately
      # complex, since they need to denormalize things, and the :media type
      # would be broken up into subtypes, etc...
      call(:"bulk_#{action}", deltas[type][action])
    end
  end
end

# This implies a response structure to "diffs_since" a bit like this:
{
  pages: {
    new: 10,
    changed: 2,
    removed: 0 },
  nodes: {
    new: 27,
    changed: 0,
    removed: 0 },
  scientific_names: {
    new: 256,
    changed: 0,
    removed: 12 },
  media: {
    new: 103,
    changed: 12,
    removed: 6 },
  etc: "etc"
}

# And then a response structure to get_diff_deltas something like this, assuming
# the params were resource_id: 1, since: "2017-01-13 10:36:25", type: "nodes",
# action: "new" page: 1, per_page: 10
{
  nodes: [
    { "repository_id"=>603,
      "page_id"=>1115346,
      "rank"=>"species",
      "parent_repository_id"=>602,
      "scientific_name"=>"<i>Echinochloa crus-galli</i> (L.) P. Beauv.",
      "canonical_form"=>"<i>Echinochloa crus-galli</i>",
      "resource_pk"=>"9786302",
      "source_url"=>
        "http://www.catalogueoflife.org/annual-checklist/details/species/id/9786302" }
  ],
  no_more_items: "true"
}
# And for action: "removed"
{
  nodes: [
    { "resource_pk"=>"9786302" }
  ],
  no_more_items: "true"
}
# And for action "changed" ... note that this allows the SITE to do
# reconciliation with curations (which occurred on that site)
{
  nodes: [
    { "resource_pk"=>"9786302",
      "repository_id"=>927845,
      "source_url"=> "http://www.catalogueoflife.org/annual-checklist/species/id/9786302" }
  ],
  no_more_items: "true"
}

# WE ARE IGNORING CURATION FOR NOW. It will be a significant question about how
# we handle it: we could either let the sites manage their own curation, so
# everyone is an island, or we could send all curation back to the harvesting
# repository. Or something in between (say, ignoring curatorial edits, or
# ignoring everything except node curation, etc). Thoughts required.
