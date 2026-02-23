Rails.application.routes.draw do
  root "products#index"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "profile", to: "users#profile", as: :profile

  resources :users, only: [ :new, :create, :destroy ]
  resources :orders, only: [ :create, :index, :show ] do
    member do
      get :invoice
    end
  end

  resource :cart, only: [ :show ]
  resources :cart_items, only: [ :create, :destroy, :update ]
  resources :products, only: [ :index, :show ]
  resources :wishlists, only: [ :index, :create, :destroy ]

  namespace :admin do
    root "dashboard#index"
    resources :products
    resources :orders, only: [ :index, :show, :update ]
  end
end
