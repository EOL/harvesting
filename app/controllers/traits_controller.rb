class TraitsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :search]

  def index
    @resource = Resource.find(params[:resource_id])
    # NOTE: you may want to add to these terms later!
    @traits = prep_for_api(
      @resource.traits.primary.published.matched
               .includes(:references, :children, :meta_traits,
                         occurrence: :occurrence_metadata,
                         node: :scientific_name)
    )
    respond_to do |fmt|
      fmt.json { render 'index', traits: @traits }
    end
  end

  def show
    @trait = Trait.where(id: params[:id])
                  .includes(:references, :children, :meta_traits,
                            occurrence: :occurrence_metadata,
                            node: :scientific_name)
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
