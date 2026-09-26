Rails.application.routes.draw do
  devise_for :users

  resources :listings, only: [:index, :show] do
    resources :bookings, only: [:new, :create]
  end

  resources :bookings, only: [:index, :show, :destroy]

  namespace :host do
    resources :listings
  end

  root "listings#index"
end