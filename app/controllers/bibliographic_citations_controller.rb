class BibliographicCitationsController < ApplicationController
  before_action :authenticate_user!
  def show
    @bibliographic_citation = BibliographicCitation.find(params[:id])
  end
end
