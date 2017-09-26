class NamesMatcher
  def self.for_harvest(harvest)
    new(harvest).start
  end

  def initialize(harvest)
    @harvest = harvest
    @resource = harvest.resource
    @root_nodes = @resource.nodes.published.root
    @strategies = [
      :match_canonical_and_authors_in_eol,
      :match_synonyms_and_authors_in_eol,
      :match_synonyms_and_authors_from_partners,
      :match_canonical_in_eol,
      :match_synonyms_in_eol,
      :match_canonical_from_partners
    ]
    @first_non_author_strategy_index = @strategies.index { |a| a !~ /authors/ }
    # variables like these really should be CONFIGURABLE, not hard-coded, so we can change a text file on the server and
    # re-run something to try new values.
    @child_match_weight = 1
    @ancestor_match_weight = 1
    @max_ancestor_depth = 2
    # If fewer (or equal to) this many ancestors match, then we assume this is just a bad match (and we never allow it),
    # regardless of how much "better" it might look than others due to sheer numbers.
    @minimum_ancestry_match_pct = 0.2

  end

  def match(name, how)
    Node.search(name.canonical, how.reverse_merge(load: false))
  end

  def match_canonical_and_authors_in_eol(name)
    match(fields: { canonical: :exact }, where: { resource_id: 1, authors: name.authors })
  end

  def match_synonyms_and_authors_in_eol(name)
    match(fields: { synonyms: :exact }, where: { resource_id: 1, synonym_authors: name.authors })
  end

  def match_synonyms_and_authors_from_partners(name)
    match(fields: { synonyms: :exact }, where: { synonym_authors: name.authors })
  end

  def match_canonical_in_eol(name)
    match(fields: { canonical: :exact }, where: { resource_id: 1 })
  end

  def match_synonyms_in_eol(name)
    match(fields: { synonyms: :exact }, where: { resource_id: 1 })
  end

  def match_canonical_from_partners(name)
    match(fields: { canonical: :exact })
  end

  # TODO: Mmmmmaybe we could do an early check (after the firtst failure?) to see if the name is there AT ALL... and
  # stop if it's not.

  def start
    map_all_nodes_to_pages(root_nodes)
  end

  # The algorithm, as pseudo-code (Ruby, for brevity):
  def map_all_nodes_to_pages(root_nodes)
    @harvest.log_mapping_started
    map_nodes(root_nodes)
    @harvest.log_mapping_completed
  end

  def map_nodes(nodes)
    nodes.each do |node|
      map_if_needed(node)
    end
  end

  def map_if_needed(node)
    if node.needs_to_be_mapped?
      strategy = 0
      # Skip scientific name searches if all we have is a canonical (really)
      strategy = @first_non_author_strategy_index if ! node.has_authority?
      map_node(node, ancestor_depth: 0, strategy: 0)
    end
    map_nodes(node.children) if node.children.any?
  end

  def map_node(node, opts = {})
    # NOTE: Surrogates never get matched in this version of the algorithm.
    return unmapped(node) if node.is_surrogate?
    # NOTE: Node.native_virus returns the "Virus" node in the DWH. NOTE: If the
    # node has been flagged (by gnparser) as a virus, then it may ONLY match other
    # viruses.
    ancestor = if node.is_virus?
      Node.native_virus
    else
      # NOTE: #matched_ancestor walks up the node's ancestors and returns the Nth #
      # non-nil page, or nil if none.
      node.matched_ancestor(opts[:ancestor_depth])
    end
    map_unflagged_node(node, ancestor, opts)
  end

  def map_unflagged_node(node, ancestor, opts)
    q = build_search_query(node, ancestor, opts)
    results = Node.search....where(q)
    if results.size == 1
      return node.map_to_page(results.first["page_id"])
    elsif results.size > 1
      return more_than_one_match(node, results)
    else # no results found! Tweak the options and try again, if possible.
      opts[:strategy] ||= 0
      opts[:strategy] += 1
      # TODO: mmmmmaybe we want to do a sanity check here and abort if the name is
      # just NOT in the database at all, and NOT go through all of the strategies.

      # TODO: MMmmmmmaybe we want a counter (across the whole resource) that, once
      # it crosses some threshold of unmapped names (OR some limit on time),
      # notifies someone. That will let us know that a resource is having trouble
      # and someone can choose to stop it or consider things.

      if @strategies[opts[:strategy]].nil?
        opts[:strategy] = @first_non_author_strategy_index
        opts[:ancestor_depth] ||= 0
        opts[:ancestor_depth] += 1
        if opts[:ancestor_depth] > @max_ancestor_depth
          # Too far! We must stop:
          return unmapped(node, opts)
        end
      end
      map_unflagged_node(node, ancestor, opts) # NOTE: recursion
    end
  end

  def more_than_one_match(node, matching_pages)
    scores = {}
    matching_pages.each do |matching_page|
      scores[matching_page] = {}
      # NOTE: #child_names will have to get the (let's go with canonical) names of
      # all the children. NOTE: #count_matches does exactly what it implies:
      # counts the number of (exactly the same) strings.
      scores[matching_page][:matching_children] =
        count_matches(matching_page.child_names, node.child_names)
      scores[matching_page][:matching_ancestors] =
        # NOTE: this is idiomatic ruby for "count the number of ancestors with
        # page_ids assigned":
        node.ancestors.select { |a| ! a.page_id.nil? }.size
      # NOTE: we are unsure of how effective this is; we really need to pay
      # attention to how this performs.
      if scores[matching_page][:matching_ancestors] <=
         ( node.ancestors.size * @minimum_ancestry_match_pct )
        scores[matching_page][:matching_ancestors] = 0
        # This is just a warning, since it won't match, but might be worth
        # investigating, since it's *possible* we're skipping a better match.
        @harvest.log_insufficient_ancestry_matches(node, matching_page)
      else
        scores[matching_page][:score] =
          scores[matching_page][:matching_children] * @child_match_weight +
          scores[matching_page][:matching_ancestors] * @ancestor_match_weight
      end
    end
    best_match = nil
    best_score = 0
    scores.each do |page, details|
      if details[:score] > best_score
        best_match = page
        best_score = details[:score]
      end
    end
    node.map_to_page(best_match["page_id"])
    # TODO: if all of the scores are 0, it's not a match, skip it.
    # TODO: if two of the scores share the best match, it's not a match, skip it. ...but log that!
    @harvest.log_multiple_matches(node, scores)
  end

  def build_search_query(node, ancestor, opts)
    strategy = @strategies[opts[:strategy]]
    q = strategy[:index].to_s
    # TODO: in Solr I think this really just becomes ":" in BOTH cases...
    q += strategy[:type] == :in ? " INCLUDES " : " = "
    q += "'#{node.send(strategy[:attribute])}'" # TODO: proper quoting, of course.
    # NOTE: we do NOT check ancestry for scientific names! We assume these will
    # match across all of life, with few exceptions.
    if ancestor && strategy[:attribute] != :scientific_name    PLUS AUTHORSHIP
      q += if opts[:other_ancestors]  # NOTE: other_ just uses resouce_id != 1
        " AND (other_ancestor_ids INCLUDES "\
          "#{ancestor.page.node_ids.join(" OR other_ancestor_ids INCLUDES ")})"
      else
        " AND ancestor_ids INCLUDES #{ancestor.page.native_node.id}"
      end
    end
    q += " AND is_hybrid = True" if node.is_hybrid?
  end

  def unmapped(node, opts = {})
    node.create_new_page
    @harvest.log_unmapped_node(node, opts)
  end
end
