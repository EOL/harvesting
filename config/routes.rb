Rails.application.routes.draw do
  root 'resources#index'

  resources :formats, only: [:show, :destroy] do
    resources :fields, only: [:create, :new]
  end
  resources :harvests
  resources :media, only: [:show]
  resources :nodes, only: [:show]
  # Required for "association" links (e.g.: in the media view)
  resources :licenses, only: [:show]
  resources :languages, only: [:show]
  resources :bibliographic_citations, only: [:show]
  resources :resources do
    get :harvest
    resources :formats, except: [:destroy]
    resources :media, only: [:index, :show]
    resources :nodes, only: [:index, :show]
    resources :scientific_names, only: [:index]
    resources :traits, only: [:index]
    resources :vernaculars, only: [:index]
  end
  resources :terms
end
