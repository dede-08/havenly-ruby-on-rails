Rails.application.routes.draw do
  devise_for :users

  resources :listings, only: [:index, :show]

  namespace :host do
    resources :listings
  end

  root "listings#index"
end