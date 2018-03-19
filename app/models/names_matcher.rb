# http://beta-repo.eol.org/nodes/1367350
# http://beta-repo.eol.org/nodes/2732271
# http://beta-repo.eol.org/nodes/3046079
# http://beta-repo.eol.org/nodes/3077300
# http://beta-repo.eol.org/nodes/3190398
# http://beta-repo.eol.org/nodes/3889294
# http://beta-repo.eol.org/nodes/4590106
# http://beta-repo.eol.org/nodes/4818899
# http://beta-repo.eol.org/nodes/4914502
# http://beta-repo.eol.org/nodes/5331812
#
# These should all have matched to the dynamic hierarchy because there is only one Liriodendron tulipifera in the DH,
# they all are perfect canonical matches, and there are no fatally conflicting ancestry data (i.e., none of them is a
# child of Metazoa, for example). Also, a whole bunch of them have family information which is a perfect match to the DH
# family.
#
# If new_node_rank=species compare only to dhierarchy_nodes with rank species, subspecies and other infraspecific ranks.
# If new_node_rank=genus compare only to dhierarchy_nodes with rank genus.
# If new_node_rank=family compare only to dhierarchy_nodes with rank family.
# If new_node_kingdom=animal, animals, metazoa, ..., compare only to dhierarchy_nodes that are descendents of animalia.
class NamesMatcher
  def self.for_harvest(harvest, options = {})
    new(harvest, options).start
  end

  def self.explain_node(node, options = {})
    harvest = node.resource.create_harvest_instance # Perhaps heavy-handed, but... simpler.
    results = []
    begin
      results = new(harvest, options).explain_node(node)
    ensure
      harvest.complete
    end
    results
  end

  def initialize(harvest, options = {})
    @harvest = harvest
    @resource = @harvest.resource
    @root_nodes = []
    @node_updates = []
    @explain = options[:explain]
    @should_update = options.key?(:update) ? options[:update] : true
    @strategies = %i[
      match_canonical_and_authors_in_eol
      match_synonyms_and_authors_in_eol
      match_synonyms_and_authors_from_partners
      match_canonical_in_eol
      match_synonyms_in_eol
      match_canonical_from_partners
    ]
    @first_non_author_strategy_index = @strategies.index { |a| a !~ /authors/ }
    # variables like these really should be CONFIGURABLE, not hard-coded, so we can change a text file on the server and
    # re-run something to try new values.
    @child_match_weight = 1
    @ancestor_match_weight = 1
    @max_ancestor_depth = 2
    # If fewer (or equal to) this many ancestors match, then we assume this is just a bad match (and we never allow it),
    # regardless of how much "better" it might look than others due to sheer numbers.
    @minimum_ancestry_match = {
      0 => 0,
      1 => 1, 2 => 1, 3 => 1, 4 => 1,
      5 => 2, 6 => 2, 7 => 2,
      8 => 3, 9 => 3
    }
    (10..250).each { |n| @minimum_ancestry_match[n] = (n * 0.3).ceil }
    @ancestors = []
    @unmatched = []
    @new_page_id = nil
    @in_unmapped_area = true
  end

  def match(name, how)
    how[:where] ||= {}
    how[:where][:canonical] = name.canonical
    how[:where][:ancestor_page_ids] = @ancestor.page_id if @ancestor
    how[:where][:is_hybrid] = true if name.hybrid?
    how[:includes] = [:scientific_name]
    how.delete(:where) if how[:where].empty?
    @harvest.log("Q: #{how.inspect}") if @explain
    results = Node.search('*', how) # TODO: .reverse_merge(load: false))  <-- not sure about this yet, so, playing safe
    @harvest.log("RESULTS (#{results.total_count}): #{results.hits.inspect}") if @explain
    results
  end

  def match_canonical_and_authors_in_eol(name)
    match(name, fields: [:canonical], where: { resource_id: 1, authors: name.authors })
  end

  def match_synonyms_and_authors_in_eol(name)
    match(name, fields: [:synonyms], where: { resource_id: 1, synonym_authors: name.authors })
  end

  def match_synonyms_and_authors_from_partners(name)
    where = { synonym_authors: name.authors }
    where[:resource_id] = { not: @resource.id } unless @resource.might_have_duplicate_taxa
    match(name, fields: [:synonyms], where: where)
  end

  def match_canonical_in_eol(name)
    match(name, fields: [:canonical], where: { resource_id: 1 })
  end

  def match_synonyms_in_eol(name)
    match(name, fields: [:synonyms], where: { resource_id: 1 })
  end

  # TODO: some resources CAN match themselves...
  def match_canonical_from_partners(name)
    match(name, fields: [:canonical], where: { resource_id: { not: @resource.id } })
  end

  def start
    @root_nodes = @resource.nodes.published.includes(:scientific_name).where(harvest_id: @harvest.id).root
    @have_names = Harvest.completed.any?
    begin
      map_all_nodes_to_pages(@root_nodes)
    ensure
      begin
        log_unmatched
      ensure
        update_nodes
      end
    end
  end

  # The algorithm, as pseudo-code (Ruby, for brevity):
  def map_all_nodes_to_pages(root_nodes)
    @harvest.log_call
    map_nodes(root_nodes)
  end

  def map_nodes(nodes)
    nodes.each do |node|
      map_if_needed(node)
    end
  end

  def explain_node(node)
    @harvest.log_call
    @explain = true
    return if skip_blank_canonical(node)
    @ancestors = node.node_ancestors.map(&:ancestor)
    @in_unmapped_area = @ancestors.empty?
    return @harvest.log("CANNOT MATCH NAMES. You haven't harvested the Dynamic Hierarchy.") unless Harvest.completed.any?
    @have_names = true
    map_node(node, ancestor_depth: 0, strategy: pick_first_strategy(node))
    # update_nodes
    @node_updates
  end

  def skip_blank_canonical(node)
    return false unless node.canonical.blank?
    @harvest.log("cannot match node with blank canonical: Node##{node.id}", cat: :warns)
    true
  end

  def map_if_needed(node)
    if skip_blank_canonical(node)
      # Nothing more to do...
    elsif node.needs_to_be_mapped?
      if node.parent_id.nil? || node.parent_id.zero? # NOTE: nil is preferred; 0 is "old school"
        @in_unmapped_area = true
        @ancestors = []
      end
      map_node(node, ancestor_depth: 0, strategy: pick_first_strategy(node))
    end
    return unless node.children.any?
    @ancestors.push(node)
    map_nodes(node.children.includes(:scientific_name))
    @ancestors.pop
  end

  def pick_first_strategy(node)
    # Skip scientific name searches if all we have is a canonical (really)
    return @first_non_author_strategy_index if node.scientific_name.authors.blank?
    0
  end

  def map_node(node, opts = {})
    return unmapped(node, 'first_import') unless @have_names
    # NOTE: Surrogates never get matched in this version of the algorithm.
    return unmapped(node, 'surrogate') if node.scientific_name.surrogate?
    @ancestor = if node.scientific_name.virus?
                  # NOTE: If the node has been flagged (by gnparser) as a virus, then it may ONLY match other viruses.
                  Node.native_virus
                else
                  matched_ancestor(opts[:ancestor_depth])
                end
    map_unflagged_node(node, opts)
  end

  def matched_ancestor(depth)
    i = 0
    @ancestors.reverse.each do |ancestor|
      next if ancestor.page_id.nil? || ancestor.in_unmapped_area?
      if i >= depth
        @in_unmapped_area = false
        return ancestor
      end
      i += 1
    end
    nil
  end

  def map_unflagged_node(node, opts)
    opts[:strategy] ||= 0
    common_exceptions = {
      'Animalia' => 1,
      'Plantae' => 281,
      'Chromista' => 3352,
      'Fungi' => 5559,
      'Protozoa' => 4651
    }
    # COMMON KINGDOMS (much easier/faster to hard-code these!):
    if common_exceptions.key?(node.scientific_name.canonical)
      return save_match(node, common_exceptions[node.scientific_name.canonical], 'common kingdom match')
    end
    results = send(@strategies[opts[:strategy]], node.scientific_name)
    if results.total_count == 1
      @node_updates << "matched node #{results.first[:id]} (Resource #{results.first[:resource_id]})"
      return save_match(node, results.first[:page_id], 'single hit')
    end
    return more_than_one_match(node, results, opts) if results.total_count > 1
    return unmapped(node, 'virus') if node.scientific_name.virus?
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
      next_ancestor = matched_ancestor(opts[:ancestor_depth])
      # Too far! We must stop:
      if opts[:ancestor_depth] > @max_ancestor_depth || next_ancestor.nil? || next_ancestor == @ancestor
        return unmapped(node, "no results (depth: #{opts[:ancestor_depth]}).")
      end
      @ancestor = next_ancestor
      opts[:strategy] = @first_non_author_strategy_index
    end
    map_unflagged_node(node, opts) # NOTE: dat recursion
  end

  def more_than_one_match(node, matching_nodes, opts = {})
    logs = ["#{matching_nodes.total_count} matches via #{@strategies[opts[:strategy]]}"]
    scores = {}
    matching_nodes.each do |matching_node|
      scores[matching_node] = {}
      scores[matching_node][:matching_children] = count_matches(matching_node.child_names, node.child_names)
      scores[matching_node][:matching_ancestors] = count_ancestors_with_page_ids_assigned
      scores[matching_node][:score] = 0
      # NOTE: we are unsure of how effective this is; we really need to pay # attention to how this performs.
      if scores[matching_node][:matching_ancestors] < @minimum_ancestry_match[@ancestors.size]
        logs << "IGNORING insufficient ancestry matches: #{scores[matching_node][:matching_ancestors]} "\
          "of #{@ancestors.size}"
        scores[matching_node][:matching_ancestors] = 0
        # This is just a warning, since it won't match, but might be worth investigating, since it's *possible* we're
        # skipping a better match.
        logs << "insufficient ancestry matches vs node #{matching_node.id} ; matches " \
          "#{scores[matching_node][:matching_ancestors]} of #{@ancestors.size}"
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
        tie = page
      end
    end
    simple_scores = {}
    if (top_scores = scores.sort_by { |_, v| 0 - v[:score] })
      top_scores[0..4].reverse.each { |k, v| simple_scores[k.id] = v }
    end
    if best_score.zero?
      logs << "best score was 0: #{simple_scores.inspect}"
      unmapped(node, logs.join('; '))
    elsif tie
      logs << "Node #{node.id} (#{node.canonical}) had a TIE (#{best_score}) for best matching name: "\
        "#{best_match.canonical} = #{scores[best_match].inspect} "\
        "VS #{tie.canonical} = #{scores[tie].inspect}"
      unmapped(node, logs.join('; '))
    else
      logs << "Node #{node.id} (#{node.canonical}) matched page #{best_match.page_id} (#{best_match.canonical}): "\
        "#{simple_scores.inspect}"
      save_match(node, best_match['page_id'], logs.join('; '))
    end
    # TODO: if two of the scores share the best match, it's not a match, skip it. ...but log that!
  end

  def save_match(node, page_id, log = nil)
    node.assign_attributes(page_id: page_id, matching_log: log)
    @node_updates << node
    true # Just avoiding a large return value.
  end

  # TODO: in_unmapped_area ...if there are no matching ancestors...
  def unmapped(node, message)
    @unmatched << "#{node.canonical} (##{node.id})"
    @in_unmapped_area = false if @resource.id == 1 # NOTE: DWH is resource ID 1, and is always "mapped"
    node.assign_attributes(page_id: new_page_id, in_unmapped_area: @in_unmapped_area, matching_log: message)
    @node_updates << node
    true # Just avoiding a large return value.
  end

  def update_nodes
    @harvest.log_call
    return if @node_updates.empty?
    unless @should_update
      @harvest.log('SKIPPPING UPDATE. (This was just an explain.)')
      return
    end
    Node.import!(@node_updates, on_duplicate_key_update: %i[page_id in_unmapped_area matching_log])
    true # Just avoiding a large return value.
  end

  def new_page_id
    # TODO: we need to be MIGHTY careful about colliding IDs, here, so we should be way more careful than this. ...but
    # to begin with, simply:
    @new_page_id ||= Node.maximum(:page_id) || 1
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

  def log_unmatched
    return if @unmatched.blank?
    if @unmatched.size > 10
      @harvest.log("#{@unmatched.size} Unmatched nodes (of #{@resource.nodes.count})! That's too many to output. "\
        "First 10: #{@unmatched[0..9].join('; ')}", cat: :names_matches)
    else
      @harvest.log("Unmatched nodes (#{@unmatched.size} of #{@resource.nodes.count}): #{@unmatched.join('; ')}",
                   cat: :names_matches)
    end
  end
end
