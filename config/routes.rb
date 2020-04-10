Rails.application.routes.draw do
  devise_for :users
  root 'resources#index'

  resources :formats, only: [:show, :destroy] do
    resources :fields, only: [:create, :new, :edit]
  end
  resources :harvests
  resources :media, only: [:show]
  resources :nodes, only: [:show] do
    get :search, on: :collection
  end
  # Required for "association" links (e.g.: in the media view)
  resources :licenses, only: [:show]
  resources :languages, only: [:show]
  resources :bibliographic_citations, only: [:show]
  resources :resources do
    get :harvest
    get :re_harvest
    get :resume_harvest
    get :re_download_opendata_harvest
    get :re_read_xml
    get :re_create_tsv
    resources :formats, except: [:destroy]
    resources :media, only: [:index, :show]
    resources :nodes, only: [:index, :show]
    resources :scientific_names, only: [:index]
    resources :traits, only: [:index]
    resources :assocs, only: [:index]
    resources :vernaculars, only: [:index]
  end
  resources :terms do
    get :new_bulk, on: :collection
    post :bulk_import, on: :collection
    get :search, on: :collection
  end
  resources :traits, only: [:show]

  get "/service/page_id_map/:resource_id" => "service/page_id_map#get", as: "page_id_map", defaults: { format: 'csv' }

  match '/ping', to: 'resources#ping', via: :all
end
