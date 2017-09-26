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
    @ancestors = []
    @new_page_id = nil
  end

  def match(name, how)
    how[:where] ||= {}
    how[:where].merge(ancestor_ids: @ancestor.id) if @ancestor
    how[:where].merge(is_hybrid: true) if name.hybrid?
    how.delete(:where) if how[:where].empty?
    Node.search(name.canonical, how) # TODO: .reverse_merge(load: false))  <-- not sure about this yet, so, playing safe
  end

  def match_canonical_and_authors_in_eol(name)
    puts "## match_canonical_and_authors_in_eol"
    match(name, fields: { canonical: :exact }, where: { resource_id: 1, authors: name.authors })
  end

  def match_synonyms_and_authors_in_eol(name)
    puts "## match_synonyms_and_authors_in_eol"
    match(name, fields: { synonyms: :exact }, where: { resource_id: 1, synonym_authors: name.authors })
  end

  def match_synonyms_and_authors_from_partners(name)
    puts "## match_synonyms_and_authors_from_partners"
    match(name, fields: { synonyms: :exact }, where: { synonym_authors: name.authors })
  end

  def match_canonical_in_eol(name)
    puts "## match_canonical_in_eol"
    match(name, fields: { canonical: :exact }, where: { resource_id: 1 })
  end

  def match_synonyms_in_eol(name)
    puts "## match_synonyms_in_eol"
    match(name, fields: { synonyms: :exact }, where: { resource_id: 1 })
  end

  def match_canonical_from_partners(name)
    puts "## match_canonical_from_partners"
    match(name, fields: { canonical: :exact })
  end

  def start
    map_all_nodes_to_pages(@root_nodes)
  end

  # The algorithm, as pseudo-code (Ruby, for brevity):
  def map_all_nodes_to_pages(root_nodes)
    @harvest.log("NamesMatcher completed", cat: :starts)
    puts "(( map_all_nodes_to_pages.start"
    map_nodes(root_nodes)
    puts ")) map_all_nodes_to_pages.end"
    @harvest.log("NamesMatcher completed", cat: :ends)
  end

  def map_nodes(nodes)
    nodes.each do |node|
      map_if_needed(node)
    end
  end

  def map_if_needed(node)
    debugger if node.canonical.blank?
    if node.needs_to_be_mapped?
      puts "++ Mapping node #{node.id} (#{node.canonical})"
      strategy = 0
      # Skip scientific name searches if all we have is a canonical (really)
      strategy = @first_non_author_strategy_index if node.scientific_name.authors.blank?
      map_node(node, ancestor_depth: 0, strategy: strategy)
    else
      puts "-- Skipping node #{node.id} (#{node.canonical})"
    end
    return unless node.children.any?
    puts ".. CHILDREN!!!"
    @ancestors.push(node)
    map_nodes(node.children)
    @ancestors.pop
  end

  def map_node(node, opts = {})
    # NOTE: Surrogates never get matched in this version of the algorithm.
    return unmapped(node, 'surrogate') if node.scientific_name.surrogate?
    @ancestor = if node.scientific_name.virus?
                  # NOTE: If the node has been flagged (by gnparser) as a virus, then it may ONLY match other viruses.
                  Node.native_virus
                else
                  matched_ancestor(node, opts[:ancestor_depth])
                end
    map_unflagged_node(node, opts)
  end

  def matched_ancestor(node, depth)
    i = 0
    @ancestors.reverse.each do |ancestor|
      unless ancestor.page_id.nil?
        return ancestor if i >= depth
        i += 1
      end
    end
    nil
  end

  def map_unflagged_node(node, opts)
    opts[:strategy] ||= 0
    results = send(@strategies[opts[:strategy]], node.scientific_name)
    return node.map_to_page(results.first[:page_id]) if results.total_count == 1
    return more_than_one_match(node, results) if results.total_count > 1
    return unmapped(node, 'virus', opts) if node.scientific_name.virus?
    opts[:strategy] += 1
    # NOTE: mmmmmaybe we want to do a sanity check here and abort if the name is
    # just NOT in the database at all, and NOT go through all of the strategies.

    # TODO: MMmmmmmaybe we want a counter (across the whole resource) that, once
    # it crosses some threshold of unmapped names (OR some limit on time),
    # notifies someone. That will let us know that a resource is having trouble
    # and someone can choose to stop it or consider things.

    if @strategies[opts[:strategy]].nil? # We've tried everything at this ancestor depth.
      opts[:ancestor_depth] ||= 1
      opts[:ancestor_depth] += 1
      next_ancestor = matched_ancestor(node, opts[:ancestor_depth])
      # Too far! We must stop:
      if opts[:ancestor_depth] > @max_ancestor_depth || next_ancestor.nil? || next_ancestor == @ancestor
        return unmapped(node, "no results (depth: #{opts[:ancestor_depth]}).", opts)
      end
      @ancestor = next_ancestor
      opts[:strategy] = @first_non_author_strategy_index
    end
    map_unflagged_node(node, opts) # NOTE: dat recursion
  end

  def more_than_one_match(node, matching_nodes)
    puts ".. Oh fun! More than one match: ##{matching_nodes.total_count}"
    scores = {}
    matching_nodes.each do |matching_node|
      scores[matching_node] = {}
      scores[matching_node][:matching_children] = count_matches(matching_node.child_names, node.child_names)
      scores[matching_node][:matching_ancestors] = count_ancestors_with_page_ids_assigned
      # NOTE: we are unsure of how effective this is; we really need to pay # attention to how this performs.
      if scores[matching_node][:matching_ancestors] <= (@ancestors.size * @minimum_ancestry_match_pct)
        puts ".. IGNORING insufficient ancestry matches: #{scores[matching_node][:matching_ancestors]} of #{@ancestors.size}"
        scores[matching_node][:matching_ancestors] = 0
        # This is just a warning, since it won't match, but might be worth investigating, since it's *possible* we're
        # skipping a better match.
        @harvest.log("insufficient ancestry matches for node #{node.id} vs node #{matching_node.id} ; matches " \
          "#{scores[matching_node][:matching_ancestors]} of #{@ancestors.size}", cat: :warns)
      else
        scores[matching_node][:score] =
          scores[matching_node][:matching_children] * @child_match_weight +
          scores[matching_node][:matching_ancestors] * @ancestor_match_weight
      end
    end
    best_match = nil
    best_score = 0
    tie = false
    scores.each do |page, details|
      if details[:score] > best_score
        best_match = page
        best_score = details[:score]
        tie = false
      elsif details[:score] == best_score
        tie = true
      end
    end
    if best_score.zero?
      unmapped(node, "best score was 0: #{scores.inspect}", opts)
    elsif tie
      @harvest.log("Node #{node.id} had a TIE for best matching name: #{scores.inspect}", cat: :warns)
      unmapped(node, "best score tied: #{scores.inspect}", opts)
    else
      @harvest.log("Node #{node.id} matched page #{best_match['page_id']}: #{scores.inspect}")
      node.map_to_page(best_match['page_id'])
    end
    # TODO: if two of the scores share the best match, it's not a match, skip it. ...but log that!
  end

  def unmapped(node, message, opts = {})
    @harvest.log("Node #{node.id} could NOT be matched: #{message} ; OPTS: #{opts.inspect}")
    node.create_new_page(new_page_id)
  end

  def new_page_id
    # TODO: we need to be MIGHTY careful about colliding IDs, here, so we should be way more careful than this. ...but
    # to begin with, simply:
    @new_page_id ||= Node.maximum(:page_id)
    @new_page_id += 1
  end

  def count_matches(one, other)
    hash = {}
    one.each { |n| hash[n] = true }
    other.count { |n| hash.key?(n) }
  end

  def count_ancestors_with_page_ids_assigned
    @ancestors.count { |a| !a.page_id.nil? }
  end
end
