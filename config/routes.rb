Rails.application.routes.draw do
  devise_for :users, only: [:sessions, :passwords] #Add registrations if necessary

  resources :stores

  get "listing" => "products#listing"

  post "new" => "registrations#create", as: :create_registration
  get "me" => "registrations#me"
  post "sign_in" => "registrations#sign_in"
  post "logout", to: "registrations#logout"
  post "canceluser", to: "registrations#canceluser"
  post "unlockuser", to: "registrations#unlockuser"

  resources :users, only: [:index, :show, :new, :create, :edit, :update, :destroy ]

  resources :stores do
    resources :products, only: [:index, :show, :create, :update, :destroy, :edit]
  end

  scope :buyers do
    resources :orders, only: [:index, :create, :update, :destroy]
  end

  root to: "welcome#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
