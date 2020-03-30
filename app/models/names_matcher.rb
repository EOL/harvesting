# This is *intended* to more or less match the rules expressed in
# https://docs.google.com/document/d/1msiuXwd19R51GaA212Gl4fIYxL3uTG831eRozPTBE5Y ... though that document is treated
# more as 'suggestions' than an actual algorithm (in the interests of speed and flexibility, not in disagreement)

# It's worth mentioning that there are two "great filters" for names-matching. The first is the search itself, which is
# necessarily exclusive. ...So if the search criteria say "match this ancestor," then any potential names matches that
# DON'T match that ancestor won't even be *considered* and will not receive a score.

# The second is the score itself. The first notable exception here is that if the search only returns a single result,
# NO SCORE IS CALCULATED This is done both in the interest of time, but also because the INTENT is that, if there really
# are exclusionary rules, they SHOULD be expressed IN THE SEARCH QUERY. That said, the score is based on a few rules,
# and the matching_node that receives the highest score will be matched.

# The next most important concept to undestand here is that there are several "strategies" for the search query itself,
# from most- to least-strict, and each strategy is applied in turn and skipped only if it yields 0 results. So, for
# example, the first strategy looks for an exact match to the scientific name including authority within the Dynamic
# Hierarchy (DH) ONLY. If that search fails, it then tries exact scientific names with authority against DH synonyms...
# and so on, I don't want to enumerate them here in the documentation, as the code itself is canonical, q.v.!

class NamesMatcher
  def self.for_harvest(harvest, process, options = {})
    new(harvest, process, options).start
  end

  # This is meant to be called manually. You can pass the second argument in as nil if you don't have a process handle.
  def self.explain_node(node, process, options = {})
    process ||= node.resource.process_log
    harvest = node.resource.create_harvest_instance # Perhaps heavy-handed, but... simpler.
    results = []
    begin
      results = new(harvest, process, options).explain_node(node)
    ensure
      harvest.complete
    end
    results
  end

  def self.fix_indexed_nodes_with_no_page_id
    results = Node.search('*', where: { page_id: nil })
    results.each do |node|
      match_one_node(node)
    end
  end

  # NOTE: this has a **bad** smell. :\ But it's kind of a one-off for fixing rare problems, so that's fine.
  def self.match_one_node(node)
    matcher = new(node.harvest, LoggedProcess.new(node.resource))
    node_id = node.id
    matcher.instance_eval do
      @logs = [] ; @have_names = true ; @ancestor = nil ; @ancestors = [] ; inode = Node.find(node_id)
      map_node(inode, ancestor_depth: 0, strategy: pick_first_strategy(inode))
      inode.matching_log = @logs.join(';')
      inode.save
    end
  end

  def initialize(harvest, process, options = {})
    @harvest = harvest
    @process = process
    @resource = @harvest.resource
    @root_nodes = []
    @node_updates = []
    @species_or_lower = {}
    Rank.species_or_lower.each { |rank| @species_or_lower[rank] = true }
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
    @child_match_weight = 1.0
    @ancestor_match_weight = 1.0
    @max_ancestor_depth = 2
    # If fewer than this many ancestors match, then we assume this is just a bad match (and we never allow it),
    # regardless of how much "better" it might look than others due to sheer numbers.
    @minimum_ancestry_match = {
      0 => 0,
      1 => 1, 2 => 1, 3 => 1, 4 => 1,
      5 => 2, 6 => 2, 7 => 2,
      8 => 3, 9 => 3
    }
    # This says "if there are 10 or more ancestors, thirty percent or more must match."
    (10..250).each { |n| @minimum_ancestry_match[n] = (n * 0.3).ceil }
    @ancestors = []
    @unmatched = []
    @new_page_id = nil
    @in_unmapped_area = true
    @resource_nodes_count = @resource.nodes.count
    @progress = @resource.nodes.where(['page_id IS NOT NULL AND in_unmapped_area = ?', false]).count
    # TODO: Logging ... @unmatched.size of @resource_nodes_count
  end

  def match(node, how)
    field = how.delete(:field) || :canonical
    how[:where] ||= { }
    # TODO - Seachkick update required: how[:where][:page_id] = { exists: true }
    how[:where][field] = node.scientific_name.canonical
    how[:where][:ancestor_page_ids] = @ancestor.page_id if @ancestor
    # If the new node is within animalia, it MUST match an animal page:
    if @ancestors.map(&:page_id).include?(1)
      how[:where][:ancestor_page_ids] =
        if how[:where][:ancestor_page_ids] && how[:where][:ancestor_page_ids] != 1
          [1, how[:where][:ancestor_page_ids]]
        else
          1
        end
    end
    how[:where][:is_hybrid] = true if node.scientific_name.hybrid?
    # Families and genera may ONLY match at that specific rank:
    if node.rank == 'family' || node.rank == 'genus'
      how[:where][:rank] = node.rank
    elsif @species_or_lower.key?(node.rank)
      # If new_node_rank=species compare only to dhierarchy_nodes with rank species, subspecies and other infraspecific
      # ranks.
      how[:where][:rank] = @species_or_lower.keys << ''
    end
    how[:includes] = [:scientific_name]
    how[:load] = false # Careful! Now you don't have models, you have a hash resembling one...
    how[:fields] = [:canonical] # It seems this shouldn't matter, since the query is '*', but, alas: it matters.
    # TODO - Seachkick update required: how[:where] = { page_id: { exists: true } } if how[:where].empty?
    how.delete(:where) if how[:where].empty?
    @process.info("Q: #{how.inspect}") if @explain
    @logs << "Q: #{how.inspect}"
    results = Node.search('*', how) # TODO: .reverse_merge(load: false))  <-- not sure about this yet, so, playing safe
    hits = results[0..9].map { |h| "#{h['id']}:#{h['canonical']}" }.join(",")
    @process.info("RESULTS (#{results.total_count}): #{hits}") if @explain
    @logs << "RESULTS (#{results.total_count}): #{hits}"
    results.to_a.delete_if {|r| r['page_id'].nil? }
  end

  def match_canonical_and_authors_in_eol(node)
    match(node, where: { resource_id: Resource.native.id, authors: node.scientific_name.authors })
  end

  def match_synonyms_and_authors_in_eol(node)
    match(node, field: :synonyms, where: { resource_id: Resource.native.id, synonym_authors: node.scientific_name.authors })
  end

  def match_synonyms_and_authors_from_partners(node)
    where = { synonym_authors: node.scientific_name.authors }
    where[:resource_id] = { not: @resource.id } unless @resource.might_have_duplicate_taxa
    match(node, field: :synonyms, where: where)
  end

  def match_canonical_in_eol(node)
    match(node, where: { resource_id: Resource.native.id })
  end

  def match_synonyms_in_eol(node)
    match(node, field: :synonyms, where: { resource_id: Resource.native.id })
  end

  # TODO: some resources CAN match themselves...
  def match_canonical_from_partners(node)
    match(node, where: { resource_id: { not: @resource.id } })
  end

  def start
    @root_nodes = @resource.nodes.published.includes(:scientific_name).where(harvest_id: @harvest.id).root
    @have_names = Harvest.completed.any?
    begin
      @process.run_step('map_all_nodes_to_pages') { map_all_nodes_to_pages(@root_nodes) }
    ensure
      begin
        log_unmatched
      ensure
        @process.run_step('update_nodes') { update_nodes }
      end
    end
  end

  # The algorithm, as pseudo-code (Ruby, for brevity):
  def map_all_nodes_to_pages(root_nodes)
    @time_per_1000 = Time.now
    @process.enter_group(@resource_nodes_count) do |harv_proc|
      @harv_proc = harv_proc # I don't want to pass this around everywhere.
      map_nodes(root_nodes)
    end
  end

  def map_nodes(nodes)
    nodes.each do |node|
      map_if_needed(node)
    end
  end

  def explain_node(node)
    @process.info("LIMITED RUN: explaining the names-matching for node #{node.id}")
    @logs = []
    @explain = true
    return if skip_blank_canonical(node)
    @ancestors = node.node_ancestors.map(&:ancestor)
    @in_unmapped_area = @ancestors.empty? || @ancestors.select(&:is_on_page_in_dynamic_hierarchy).empty?
    return @process.info("CANNOT MATCH NAMES. You haven't harvested the Dynamic Hierarchy.") unless
      Harvest.completed.any?
    @have_names = true
    map_node(node, ancestor_depth: 0, strategy: pick_first_strategy(node))
    @node_updates
  end

  def skip_blank_canonical(node)
    return false unless node.canonical.blank?
    @process.warn("cannot match node with blank canonical: Node##{node.id}")
    true
  end

  def map_if_needed(node)
    @logs = []
    if skip_blank_canonical(node)
      unmapped(node, 'blank_canonical')
    elsif node.needs_to_be_mapped?
      if node.parent_id.nil? || node.parent_id.zero? # NOTE: nil is preferred; 0 is "old school"
        @in_unmapped_area = true
        @ancestors = []
      end
      map_node(node, ancestor_depth: 0, strategy: pick_first_strategy(node))
    end
    return unless node.children.any?
    @ancestors.push(node)
    # Some nodes can have hundreds of thousands of children (ITIS's Animalia has 485,935), so we do children in batches:
    node.children.pluck(:id).in_groups_of(1000) do |node_ids|
      map_nodes(Node.where(id: node_ids).includes(:scientific_name))
    end
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
      next unless ancestor.is_on_page_in_dynamic_hierarchy?
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
      'Animal' => 1,
      'Animals' => 1,
      'Chromista' => 3352,
      'Fungi' => 5559,
      'Metazoa' => 1,
      'Metazoan' => 1,
      'Plantae' => 281,
      'Protozoa' => 4651
    }
    # COMMON KINGDOMS (much easier/faster to hard-code these!):
    if common_exceptions.key?(node.scientific_name.canonical)
      return save_match(node, common_exceptions[node.scientific_name.canonical], 'common kingdom match')
    end
    @logs << @strategies[opts[:strategy]]
    results = send(@strategies[opts[:strategy]], node)
    # TODO - After Searchkick upgrade: if results.total_count == 1
    if results.size == 1
      @logs << "matched node #{results.first[:id]} (Resource #{results.first[:resource_id]})"
      return save_match(node, results.first[:page_id], 'single hit')
    end
    # TODO - After Searchkick upgrade: return more_than_one_match(node, results, opts) if results.total_count > 1
    return more_than_one_match(node, results, opts) if results.size > 1
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
    @logs << "#{matching_nodes.size} matches via #{@strategies[opts[:strategy]]}"
    # TODO: @logs << "#{matching_nodes.total_count} matches via #{@strategies[opts[:strategy]]}"
    scores = {}
    matching_nodes.each do |matching_node|
      scores[matching_node] = {}
      scores[matching_node][:matching_children] = count_matches(matching_node.children, node.child_names)
      scores[matching_node][:matching_ancestors] = matching_ancestors(matching_node)
      scores[matching_node][:matching_family] = family_matched?(matching_node)
      scores[matching_node][:sameness_of_names] = sameness_of_names(node, matching_node)
      scores[matching_node][:score] = 0.0
      # NOTE: we are unsure of how effective this is; we really need to pay attention to how this performs.
      if !scores[matching_node][:matching_family] &&
         scores[matching_node][:matching_ancestors] < @minimum_ancestry_match[@ancestors.size]
        @logs << "IGNORING insufficient ancestry matches: #{scores[matching_node][:matching_ancestors]} "\
          "of #{@ancestors.size}"
        scores[matching_node][:matching_ancestors] = 0
        # This is just a warning, since it won't match, but might be worth investigating, since it's *possible* we're
        # skipping a better match.
        @logs << "insufficient ancestry matches vs node #{matching_node.id} ; matches " \
          "#{scores[matching_node][:matching_ancestors]} of #{@ancestors.size}"
      else
        scores[matching_node][:score] =
          scores[matching_node][:matching_children] * @child_match_weight +
          scores[matching_node][:matching_ancestors] * @ancestor_match_weight
        scores[matching_node][:score] *= 2.0 if scores[matching_node][:matching_family]
        scores[matching_node][:score] *= scores[matching_node][:sameness_of_names]
      end
    end
    best_match = nil
    best_score = 0.0
    tie = false
    scores.each do |node_hash, details|
      if details[:score] > best_score
        best_match = node_hash
        best_score = details[:score]
        tie = false
      elsif details[:score] == best_score
        tie = node_hash
      end
    end
    simple_scores = {}
    if (top_scores = scores.sort_by { |_, v| 0.0 - v[:score] })
      top_scores[0..4].reverse.each { |k, v| simple_scores[k['id']] = v }
    end
    if best_score < 0.1
      @logs << "best score was too low: #{simple_scores.inspect}"
      unmapped(node)
    elsif tie
      @logs << "Node #{node.id} (#{node.canonical}) had a TIE (#{best_score}) for best matching name: "\
        "#{best_match['id']} = #{simple_scores[best_match['id']].inspect} "\
        "VS #{tie['id']} = #{simple_scores[best_match['id']].inspect}"
      unmapped(node)
    else
      @logs << "Node #{node.id} (#{node.canonical}) matched page #{best_match['page_id']} (#{best_match['canonical']}): "\
        "#{simple_scores.inspect}"
      save_match(node, best_match['page_id'])
    end
    # TODO: if two of the scores share the best match, it's not a match, skip it. ...but log that!
  end

  def save_match(node, page_id, message = nil)
    @logs << message if message
    # NOTE: only grabbing the end of the matching log, if it's too long...
    node.assign_attributes(page_id: page_id, matching_log: @logs.join('; ')[-65_500..-1])
    update_node(node)
    tick_progress
  end

  # TODO: in_unmapped_area ...if there are no matching ancestors...
  def unmapped(node, message = nil)
    @logs << message if message
    @unmatched << "#{node.canonical} (##{node.id})"
    @in_unmapped_area = false if @resource.native?
    node.assign_attributes(page_id: new_page_id, in_unmapped_area: @in_unmapped_area, matching_log: @logs.join('; ')[-65_500..-1])
    update_node(node)
    tick_progress
  end

  def update_node(node)
    @node_updates << node
    update_nodes if @node_updates.size >= 100_000
    true # Just avoiding a large return value
  end

  def tick_progress
    return unless @harv_proc
    @progress += 1
    @harv_proc.update_group(@progress, Time.now - @time_per_1000) if (@progress % 1000).zero?
    @time_per_1000 = Time.now
  end

  def update_nodes
    return if @node_updates.empty?
    unless @should_update
      @process.info('SKIPPPING UPDATE.')
      return
    end
    Node.import!(@node_updates, on_duplicate_key_update: %i[page_id in_unmapped_area matching_log])
    @node_updates = []
  end

  def new_page_id
    # TODO: we need to be MIGHTY careful about colliding IDs, here, so we should be way more careful than this. ...but
    # to begin with, simply:
    @new_page_id ||= Node.maximum(:page_id) || 1
    @new_page_id += 1
  end

  def count_matches(one, other)
    return nil if one.nil? || other.nil?
    (one & other).size
  end

  def matching_ancestors(matching_node)
    (matching_node[:ancestor_page_ids].sort & @ancestors.map(&:page_id)).size
  end

  def family_matched?(matching_node)
    raise "You need to reindex your Nodes, sorry." unless matching_node[:ancestor_ranks]
    family_index = matching_node[:ancestor_ranks].index('family')
    return nil if family_index.nil?
    family_page = matching_node[:ancestor_page_ids][family_index]
    @ancestors.map(&:page_id).include?(family_page)
  end

  def sameness_of_names(node, other)
    if node.canonical == other[:canonical]
      if node.authors == other[:authors]
        2.0 # Excellent match.
      else
        1.0
      end
    else
      0.5 # Partial match
    end
  end

  def log_unmatched
    if @unmatched.blank?
      @process.info("ZERO unmatched nodes (of #{@resource_nodes_count})! Nicely done.")
    elsif @unmatched.size > 10
      @process.info("#{@unmatched.size} Unmatched nodes (of #{@resource_nodes_count})! That's too many to output. "\
        "First 10: #{@unmatched[0..9].join('; ')}")
    else
      @process.info("Unmatched nodes (#{@unmatched.size} of #{@resource_nodes_count}): #{@unmatched.join('; ')}")
    end
  end
end
