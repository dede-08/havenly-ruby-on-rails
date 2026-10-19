Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  devise_for :users

  resources :listings, only: [ :index, :show ] do
    resources :bookings, only: [ :new, :create ]
  end

  resources :bookings, only: [ :index, :show, :destroy ] do
    resource :checkout, only: [ :new ], controller: "checkouts"
    resource :review, only: [ :new, :create ]
  end

  namespace :host do
    resources :listings
  end

  post "/webhooks/stripe", to: "stripe_webhooks#create"

  root "listings#index"
end
