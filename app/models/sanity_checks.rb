class SanityChecks
  TRAIT_COMPARISON_COLS = [
    'node_id', 
    'predicate_term_uri',
    'object_term_uri',
    'statistical_method_term_uri',
    'sex_term_uri',
    'lifestage_term_uri',
    'measurement',
    'literal',
    'source',
    'citation',
  ]

  ASSOC_COMPARISON_COLS = [
    'predicate_term_uri',
    'node_id',
    'target_node_id',
    'sex_term_uri',
    'lifestage_term_uri'
  ]

  def initialize(harvest, process)
    @harvest = harvest
    @process = process
  end

  def perform_all
    check_for_duplicate_traits
    check_for_duplicate_assocs
  end

  def check_for_duplicate_traits
    check_for_duplicates(Trait, 'trait', 'trait', TRAIT_COMPARISON_COLS)
  end

  def check_for_duplicate_assocs
    check_for_duplicates(Assoc, 'assoc', 'association', ASSOC_COMPARISON_COLS)
  end

  def log_duplicates(klass, type, name, cols)
    table = type + 's'

    q = <<~SQL
      SELECT t1.resource_pk, t1.id, t2.resource_pk, t2.id
      FROM #{table} t1 JOIN #{table} t2 ON 
      #{cols.map { |c| "coalesce(t1.#{c}, 'null') = coalesce(t2.#{c}, 'null')" }.join("AND\n")} AND
      t1.id < t2.id AND
      t1.harvest_id = #{@harvest.id} AND t2.harvest_id = #{@harvest.id}
      LEFT OUTER JOIN #{table}_references r1 ON r1.#{type}_id = t1.id 
      LEFT OUTER JOIN #{table}_references r2 ON r2.#{type}_id = t2.id
      WHERE r1.reference_id <=> r2.reference_id
      LIMIT 100
    SQL

    result = klass.connection.execute(q)

    @process.log("Duplicate #{name} pairs (up to 100):") 
    
    result.each do |r|
      @process.log("(resource_pk: #{r[0]}, id: #{r[1]}), (resource_pk: #{r[2]}, id: #{r[3]})")
    end
  end

  def check_for_duplicates(klass, type, name, cols)
    table = type + 's'
    ref_join_table = "#{table}_references"

    all_count = @harvest.send(table).count
    count_q = <<~SQL
      SELECT count(DISTINCT
        concat_ws(',',
          #{cols.map { |c| "coalesce(#{table}.#{c}, 'null')" }.join(",\n")},
          coalesce(#{ref_join_table}.reference_id, 'null')
        ))
      FROM #{table} LEFT OUTER JOIN #{ref_join_table} ON #{table}.id = #{ref_join_table}.#{type}_id
      WHERE #{table}.harvest_id = #{@harvest.id}
    SQL

    uniq_count = klass.connection.execute(count_q).first.first
    diff = all_count - uniq_count 

    unless diff == 0
      @process.log("DUPLICATE TRAITS FOUND! There are only #{uniq_count} (of #{all_count} total) unique #{name}s.")
      log_duplicates(klass, type, name, cols)
    end
  end
end

