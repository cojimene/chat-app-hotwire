Rails.application.routes.draw do
  resources :rooms
  devise_for :users
  post 'add/user', to: 'rooms#add_user'

  # Defines the root path route ("/")
  root "rooms#index"
end
