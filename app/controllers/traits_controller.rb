class TraitsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :search]

  @@simple_meta_fields = %i[predicate_term object_term]
  @@meta_fields = @@simple_meta_fields + %i[units_term statistical_method_term]
  @@property_fields = @@meta_fields + %i[sex_term lifestage_term references]

  def index
    @resource = Resource.find(params[:resource_id])
    # NOTE: you may want to add to these terms later!
    @traits = prep_for_api(
      @resource.traits.primary.published.matched
               .includes(@@property_fields,
                         children: @@meta_fields,
                         occurrence: { occurrence_metadata: @@simple_meta_fields },
                         node: :scientific_name,
                         meta_traits: @@meta_fields)
    )
    respond_to do |fmt|
      fmt.json { render 'index', traits: @traits }
    end
  end

  def show
    @trait = Trait.where(id: params[:id])
                  .includes(@@property_fields,
                            children: @@meta_fields,
                            occurrence: { occurrence_metadata: @@simple_meta_fields },
                            node: :scientific_name,
                            meta_traits: @@meta_fields)
                  .first
    @resource = @trait.resource
    @harvest = @trait.harvest
    @format = @harvest.formats.where(represents: Format.represents[:measurements]).first
    @heads = `head -n 1 #{@format.get_from}`
    @cmd =
      if @trait.resource_pk == @trait.resource_pk.to_i.to_s
        "head -n #{@trait.resource_pk.to_i + @format.header_lines - 1} #{@format.get_from} | tail -n 3"
      else
        %(grep "\\<#{@trait.resource_pk}\\>" #{@format.get_from})
      end
    @lines = `#{@cmd}`.split("\n")
  end
end
