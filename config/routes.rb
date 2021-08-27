Rails.application.routes.draw do
  devise_for :users
  root 'resources#index'

  resources :formats, only: [:show]
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
    get :unlock
    get :re_harvest
    get :resume_harvest
    get :remove_content
    get :re_download_opendata_harvest
    get :re_read_xml
    get :re_create_tsv
    delete :trait_publish_files
    resources :formats, only: [:show]
    resources :media, only: [:index, :show]
    resources :nodes, only: [:index, :show]
    resources :scientific_names, only: [:index]
    resources :traits, only: [:index]
    resources :assocs, only: [:index]
    resources :vernaculars, only: [:index]

    nested do
      get 'publish_diffs' => 'publish_diffs#show'
    end

    collection do
      get 'kill_workers'
    end
  end
  resources :traits, only: [:show]

  get "/service/page_id_map/:resource_id" => "service/page_id_map#get", as: "page_id_map", defaults: { format: 'csv' }

  match '/ping', to: 'resources#ping', via: :all
end
