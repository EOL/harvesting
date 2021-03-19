class SanityChecks

  def initialize(harvest, process)
    @harvest = harvest
    @process = process
  end

  def perform_all
    check_for_duplicate_traits
  end

  def check_for_duplicate_traits
    all_count = @harvest.traits.count
    uniq_count = @harvest.traits.count(
      <<~SQL
        DISTINCT(
        concat_ws(',',
          coalesce(node_id, 'n'), 
          coalesce(predicate_term_uri, 'n'),
          coalesce(object_term_uri, 'n'),
          coalesce(statistical_method_term_uri, 'n'),
          coalesce(sex_term_uri, 'n'), 
          coalesce(lifestage_term_uri, 'n'), 
          coalesce(measurement, 'n'), 
          coalesce(literal, 'n')
        ))
      SQL
    )

    diff = @harvest.traits.count - uniq_count 

    unless diff == 0
      @process.log("DUPLICATE TRAITS FOUND! There are only #{uniq_count} (of #{all_count} total) unique traits.")
      log_duplicate_trait_ids
    end
  end

  def log_duplicate_trait_ids
    trait_id_q = <<~SQL
      SELECT t1.resource_pk, t1.id, t2.resource_pk, t2.id FROM
      traits t1 JOIN traits t2
      ON 
      coalesce(t1.node_id, 'n') = coalesce(t2.node_id, 'n') AND
      coalesce(t1.predicate_term_uri, 'n') = coalesce(t2.predicate_term_uri, 'n') AND
      coalesce(t1.object_term_uri, 'n') = coalesce(t2.object_term_uri, 'n') AND 
      coalesce(t1.statistical_method_term_uri, 'n') = coalesce(t2.statistical_method_term_uri, 'n') AND
      coalesce(t1.sex_term_uri, 'n') = coalesce(t2.sex_term_uri, 'n') AND
      coalesce(t1.lifestage_term_uri, 'n') = coalesce(t2.lifestage_term_uri, 'n') AND 
      coalesce(t1.measurement, 'n') = coalesce(t2.measurement, 'n') AND
      coalesce(t1.literal, 'n') = coalesce(t2.literal, 'n') AND
      t1.id < t2.id AND
      t1.harvest_id = #{@harvest.id} AND t2.harvest_id = #{@harvest.id}
      LIMIT 100
    SQL

    result = Trait.connection.execute(trait_id_q)

    @process.log("Duplicate trait pairs (up to 100):") 
    
    result.each do |r|
      @process.log("(resource_pk: #{r[0]}, id: #{r[1]}), (resource_pk: #{r[2]}, id: #{r[3]})")
    end
  end
end
