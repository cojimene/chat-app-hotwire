Rails.application.routes.draw do
  resources :rooms do
    resources :messages, only: %i[edit create destroy update], shallow: true
  end

  devise_for :users
  post 'add/user', to: 'rooms#add_user'

  # Defines the root path route ("/")
  root "rooms#index"
end
