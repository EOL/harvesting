class BibliographicCitationsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  def show
    @bibliographic_citation = BibliographicCitation.find(params[:id])
  end
end
