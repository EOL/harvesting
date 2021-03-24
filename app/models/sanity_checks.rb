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
    check_for_no_provenance(Trait, 'trait', 'trait', ['source', 'citation'])
    check_for_no_provenance(Assoc, 'assoc', 'association', ['source'])
  end

  private

  def check_for_duplicate_traits
    check_for_duplicates(Trait, 'trait', 'trait', TRAIT_COMPARISON_COLS)
  end

  def check_for_duplicate_assocs
    check_for_duplicates(Assoc, 'assoc', 'association', ASSOC_COMPARISON_COLS)
  end

  def check_for_no_provenance(klass, type, name, cols)
    count_q = <<~SQL
      SELECT count(*)
      #{no_provenance_query_common(type, name, cols)}
    SQL

    count = klass.connection.execute(count_q).first.first

    unless count == 0
      @process.log("TRAITS WITHOUT PROVENANCE FOUND! There are #{count} traits w/o #{cols.join(', ')} or references.")
      log_no_provenance(klass, type, name, cols)
    end
  end

  def log_no_provenance(klass, type, name, cols)
    q = <<~SQL
      SELECT #{table(type)}.resource_pk, #{table(type)}.id 
      #{no_provenance_query_common(type, name, cols)}
    SQL

    result = klass.connection.execute(q)

    @process.log("#{name}s w/o provenance (up to 100):") 

    result.each do |r|
      @process.log("(resource_pk: #{r[0]}, id: #{r[1]})")
    end
  end

  def log_duplicates(klass, type, name, cols)
    q = <<~SQL
      SELECT t1.resource_pk, t1.id, t2.resource_pk, t2.id
      FROM #{table(type)} t1 JOIN #{table(type)} t2 ON 
      #{cols.map { |c| "coalesce(t1.#{c}, 'null') = coalesce(t2.#{c}, 'null')" }.join("AND\n")} AND
      t1.id < t2.id AND
      t1.harvest_id = #{@harvest.id} AND t2.harvest_id = #{@harvest.id}
      LEFT OUTER JOIN #{table(type)}_references r1 ON r1.#{type}_id = t1.id 
      LEFT OUTER JOIN #{table(type)}_references r2 ON r2.#{type}_id = t2.id
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
    ref_join_table = "#{table(type)}_references"

    all_count = @harvest.send(table(type)).count
    count_q = <<~SQL
      SELECT count(DISTINCT
        concat_ws(',',
          #{cols.map { |c| "coalesce(#{table(type)}.#{c}, 'null')" }.join(",\n")},
          coalesce(#{ref_join_table}.reference_id, 'null')
        ))
      FROM #{table(type)} LEFT OUTER JOIN #{ref_join_table} ON #{table(type)}.id = #{ref_join_table}.#{type}_id
      WHERE #{table(type)}.harvest_id = #{@harvest.id}
    SQL

    uniq_count = klass.connection.execute(count_q).first.first
    diff = all_count - uniq_count 

    unless diff == 0
      @process.log("DUPLICATE TRAITS FOUND! There are only #{uniq_count} (of #{all_count} total) unique #{name}s.")
      log_duplicates(klass, type, name, cols)
    end
  end

  def no_provenance_query_common(type, name, cols)
    ref_join_table = "#{table(type)}_references"

    <<~SQL
      FROM #{table(type)} LEFT OUTER JOIN #{ref_join_table}
      ON #{table(type)}.id = #{ref_join_table}.#{type}_id
      WHERE #{table(type)}.harvest_id = #{@harvest.id}
      AND #{cols.map { |col| "(#{table(type)}.#{col} IS NULL OR #{table(type)}.#{col} = '')"}.join(" AND ") }
      AND #{ref_join_table}.reference_id IS NULL
    SQL
  end

  def table(type)
    type + 's'
  end
end

