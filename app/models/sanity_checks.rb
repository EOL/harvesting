class SanityChecks
  TRAIT_COMPARISON_COLS = [
    'node_id', 
    'predicate_term_uri',
    'object_term_uri',
    'statistical_method_term_uri',
    'sex_term_uri',
    'lifestage_term_uri',
    'measurement',
    'literal'
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
    check_for_duplicates(Trait, 'traits', 'trait', TRAIT_COMPARISON_COLS)
  end

  def check_for_duplicate_assocs
    check_for_duplicates(Assoc, 'assocs', 'association', ASSOC_COMPARISON_COLS)
  end

  def log_duplicates(klass, table, name, cols)
    q = <<~SQL
      SELECT t1.resource_pk, t1.id, t2.resource_pk, t2.id FROM
      #{table} t1 JOIN #{table} t2
      ON 
      #{cols.map { |c| "coalesce(t1.#{c}, 'null') = coalesce(t2.#{c}, 'null')" }.join("AND\n")} AND
      t1.id < t2.id AND
      t1.harvest_id = #{@harvest.id} AND t2.harvest_id = #{@harvest.id}
      LIMIT 100
    SQL

    result = klass.connection.execute(q)

    @process.log("Duplicate #{name} pairs (up to 100):") 
    
    result.each do |r|
      @process.log("(resource_pk: #{r[0]}, id: #{r[1]}), (resource_pk: #{r[2]}, id: #{r[3]})")
    end
  end

  def check_for_duplicates(klass, table, name, cols)
    all_count = @harvest.send(table).count
    uniq_count = @harvest.send(table).count(
      <<~SQL
        DISTINCT(
        concat_ws(',',
          #{cols.map { |c| "coalesce(#{c}, 'null')" }.join(",\n")}
        ))
      SQL
    )

    diff = all_count - uniq_count 

    unless diff == 0
      @process.log("DUPLICATE TRAITS FOUND! There are only #{uniq_count} (of #{all_count} total) unique #{name}s.")
      log_duplicates(klass, table, name, cols)
    end
  end
end

