Rails.application.routes.draw do
  root 'resources#index'

  resources :formats, only: [:show, :destroy] do
    resources :fields, only: [:create, :new]
  end
  resources :harvests
  resources :media, only: [:show]
  resources :nodes, only: [:show]
  resources :resources do
    resources :media, only: [:index, :show]
    resources :nodes, only: [:index, :show]
    resources :scientific_names, only: [:index]
    resources :formats, except: [:destroy]
    resources :traits, only: [:index]
  end
  resources :terms
end
