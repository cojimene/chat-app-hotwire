Rails.application.routes.draw do
  resources :rooms do
    post :add_user, on: :member

    resources :messages, shallow: true do
      get :actions, on: :member
    end
  end

  devise_for :users

  # Defines the root path route ("/")
  root "rooms#index"
end
