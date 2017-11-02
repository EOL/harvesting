class BibliographicCitationsController < ApplicationController
  def show
    @bibliographic_citation = BibliographicCitation.find(params[:id])
  end
end
