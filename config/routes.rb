Rails.application.routes.draw do
  devise_for :users

  resources :listings, only: [:index, :show] do
    resources :bookings, only: [:new, :create]
  end

  resources :bookings, only: [:index, :show, :destroy] # "Mis reservas" del guest
  root "listings#index"
end