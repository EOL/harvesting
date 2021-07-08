class PublishMetadatum < ApplicationRecord
  belongs_to :publish_trait

  SKIP_METADATA_PRED_URIS = Set.new([
    "http://rs.tdwg.org/dwc/terms/lifestage",
    "http://rs.tdwg.org/dwc/terms/sex"
  ])

  class << self
    def from_meta(meta, publish_trait)
      literal = nil
      predicate = nil

      if meta.is_a?(Reference)
        # TODO: we should probably make this URI configurable:
        predicate = 'http://eol.org/schema/reference/referenceID'
        body = meta.body || ''
        body += " <a href='#{meta.url}'>link</a>" unless meta.url.blank?
        body += " #{meta.doi}" unless meta.doi.blank?
        literal = body
      elsif SKIP_METADATA_PRED_URIS.include?(UrisAreEolTerms.new(meta).uri(:predicate_term_uri)&.downcase)
        # these are written as fields in the traits file, so skip (associations are populated from OccurrenceMetadata in
        # ResourceHarvester#resolve_trait_keys)
        return nil
      elsif (meta_mapping = moved_meta_mapping(meta.predicate_term_uri))
        raise TypeError, "moved meta encountered without an in-harvest trait" if publish_trait.nil?
        value = meta.literal
        value = meta.measurement if meta_mapping[:from] && meta_mapping[:from] == :measurement
        publish_trait.send("#{meta_mapping[:to]}=", value)
        return nil # Don't record this one.
      else
        literal = meta.literal
        predicate = UrisAreEolTerms.new(meta).uri(:predicate_term_uri)
      end

      self.new({
        predicate_uri: predicate,
        literal: literal,
        measurement: meta.respond_to?(:measurement) ? meta.measurement : nil,
        value_uri: UrisAreEolTerms.new(meta).uri(:object_term_uri),
        units_uri: UrisAreEolTerms.new(meta).uri(:units_term_uri),
        sex_uri: UrisAreEolTerms.new(meta).uri(:sex_term_uri),
        lifestage_uri: UrisAreEolTerms.new(meta).uri(:lifestage_term_uri),
        statistical_method_uri: UrisAreEolTerms.new(meta).uri(:statistical_method_term_uri),
        source_uri: UrisAreEolTerms.new(meta).uri(:source),
        is_external_meta: meta.respond_to?(:external_meta?) ? meta.external_meta? : false
      })
    end

    private

    def moved_meta_mapping(uri)
      @moved_meta_map ||= {
        'http://eol.org/schema/terms/samplesize' => { from: :measurement, to: :sample_size },
        'http://purl.org/dc/terms/bibliographiccitation' => { to: :citation },
        'http://purl.org/dc/terms/source' => { to: :source },
        'http://rs.tdwg.org/dwc/terms/measurementremarks' => { to: :remarks },
        'http://rs.tdwg.org/dwc/terms/measurementmethod' => { to: :method }
      }

      @moved_meta_map[uri.downcase]
    end
  end

  def eol_pk
    id
  end

  def predicate
    predicate_uri
  end

  def units_uri
    units
  end

  def source
    source_uri
  end

  def lifestage
    lifestage_uri
  end

  def sex
    sex_uri
  end

  def statistical_method
    statistical_method_uri
  end

  def digest
    attr_str = [
      predicate_uri,
      literal,
      measurement,
      value_uri,
      units_uri,
      sex_uri,
      lifestage_uri,
      statistical_method_uri,
      source_uri,
      is_external_meta
    ].join('|')

    Digest::MD5.hexdigest attr_str
  end
end
