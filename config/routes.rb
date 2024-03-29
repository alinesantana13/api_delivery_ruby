Rails.application.routes.draw do
  devise_for :users
  resources :stores
  get "listing" => "products#listing"
  root to: "welcome#index"
  
  get "up" => "rails/health#show", as: :rails_health_check
end
