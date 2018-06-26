class TermsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :search]

  def index
    params[:per_page] ||= 50
    @terms = prep_for_api(Term.order(params[:by_position] ? :position : %i[name uri]), updated: true)
  end

  def search
    params[:per_page] ||= 50
    terms = Term.order(params[:by_position] ? :position : %i[name uri])
    terms = terms.where(['name LIKE ?', "%#{params[:name]}%"]) if params[:name]
    terms = terms.where(['uri LIKE ?', "%#{params[:uri]}%"]) if params[:uri]
    @terms = prep_for_api(terms, updated: true)
    render :index
  end

  def new_bulk
    log_auth(Term)
  end

  def bulk_import
    log_auth(Term)
    flash[notice] =
      begin
        terms = params[:terms]
        terms.sub!(/, { ... another one ... }/m, '')
        terms = "[#{terms}" unless terms.match?(/^\[/)
        terms = "#{terms}]" unless terms.match?(/]$/)
        json = JSON.parse(terms)
        id = Term.last.id
        Term.from_json(json)
        "Created #{Term.last.id - id} term(s). (Note that updated terms aren't included in this count; "\
          'they probably updated if you are seeing this.)'
      rescue => e
        e.message
      end
    redirect_to terms_path
  end

  def show
    @term = Term.find(params[:id])
  end

  def new
    @term = Term.new()
    log_auth(@term)
  end

  def edit
    @term = Term.find(params[:id])
    log_auth(@term)
  end

  def create
    @term = Term.new(term_params)
    log_auth(@term)
    if @term.save
      name = @term.name
      name = @term.uri if name.blank?
      flash[:notice] = I18n.t('terms.flash.created', name: name, path: term_path(@term)).html_safe
      redirect_to terms_path
    else
      # TODO: some kind of hint as to the problem, in a flash...
      render 'new'
    end
  end

  def update
    @term = Term.find(params[:id])
    log_auth(@term)
    old_pos = @term.position
    @term.position.update(params[:term][:position]) rescue nil # Hack, but I'm in a rush.
    if @term.update(term_params)
      name = @term.name
      name = @term.uri if name.blank?
      flash[:notice] = I18n.t('terms.flash.edited', name: name, path: term_path(@term)).html_safe
      redirect_to @term
    else
      # TODO: some kind of hint as to the problem, in a flash...
      render 'new'
    end
  end

  def term_params
    params.require(:term).permit(
      %i[uri name used_for is_hidden_from_overview is_hidden_from_glossary is_text_only is_verbatim_only uri definition
         comment attribution ontology_information_url ontology_source_url ontology_source_url position]
    )
  end

  def destroy
    @term = Term.find(params[:id])
    log_auth(@term)
    name = @term.name
    name = @term.uri if name.blank?
    @term.destroy
    redirect_to resources_path, notice: I18n.t('terms.flash.destroyed', name: name)
  end
end
