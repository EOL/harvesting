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
    'source'
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
    check_for_no_source(Trait, 'trait', 'trait')
    check_for_no_source(Assoc, 'assoc', 'association')
  end

  private

  def check_for_duplicate_traits
    check_for_duplicates(Trait, 'trait', 'trait', TRAIT_COMPARISON_COLS)
  end

  def check_for_duplicate_assocs
    check_for_duplicates(Assoc, 'assoc', 'association', ASSOC_COMPARISON_COLS)
  end

  def check_for_no_source(klass, type, name)
    count_q = <<~SQL
      SELECT count(*)
      #{no_source_query_common(type, name)}
    SQL

    count = klass.connection.execute(count_q).first.first

    unless count == 0
      @process.log("WARNING: #{count} #{name}(s) without source found! Please confirm that this is intentional.")
      log_no_source(klass, type, name)
    end
  end

  def log_no_source(klass, type, name)
    q = <<~SQL
      SELECT #{table(type)}.resource_pk, #{table(type)}.id 
      #{no_source_query_common(type, name)}
      LIMIT 100
    SQL

    result = klass.connection.execute(q)

    @process.log("#{name}s w/o source (up to 100):") 

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
      LIMIT 100
    SQL

    result = klass.connection.execute(q)

    @process.log("(Near) duplicate #{name} pairs (up to 100):") 
    
    result.each do |r|
      @process.log("(resource_pk: #{r[0]}, id: #{r[1]}), (resource_pk: #{r[2]}, id: #{r[3]})")
    end
  end

  def check_for_duplicates(klass, type, name, cols)
    all_count = @harvest.send(table(type)).count
    count_q = <<~SQL
      SELECT count(DISTINCT
        concat_ws(',',
          #{cols.map { |c| "coalesce(#{table(type)}.#{c}, 'null')" }.join(",\n")}
        ))
      FROM #{table(type)}
      WHERE #{table(type)}.harvest_id = #{@harvest.id}
    SQL

    uniq_count = klass.connection.execute(count_q).first.first
    diff = all_count - uniq_count 

    unless diff == 0
      @process.log("(NEAR) DUPLICATE TRAITS FOUND! There are only #{uniq_count} (of #{all_count} total) unique #{name}s.")
      log_duplicates(klass, type, name, cols)
    end
  end

  def no_source_query_common(type, name)
    ref_join_table = "#{table(type)}_references"

    <<~SQL
      FROM #{table(type)} LEFT OUTER JOIN #{ref_join_table}
      ON #{table(type)}.id = #{ref_join_table}.#{type}_id
      WHERE #{table(type)}.harvest_id = #{@harvest.id}
      AND (#{table(type)}.source IS NULL OR #{table(type)}.source = '')
      AND #{ref_join_table}.reference_id IS NULL
    SQL
  end

  def table(type)
    type + 's'
  end
end

