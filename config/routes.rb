Rails.application.routes.draw do
  devise_for :users
  resources :stores
  get "listing" => "products#listing"

  get "storeslist" => "registrations#storeslist"

  post "new" => "registrations#create", as: :create_registration

  get "me" => "registrations#me"

  post "sign_in" => "registrations#sign_in"

  post "logout", to: "registrations#logout"

  post "canceluser", to: "registrations#canceluser"

  post "unlockuser", to: "registrations#unlockuser"

  root to: "welcome#index"
  
  get "up" => "rails/health#show", as: :rails_health_check
end
