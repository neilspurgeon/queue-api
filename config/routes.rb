Rails.application.routes.draw do
  scope :api, defaults: {format: :json} do
    devise_for :users, :controllers => {
      :sessions => 'v1/sessions',
      :registrations => 'v1/registrations'
    }

    namespace :v1 do

      devise_scope :user do
        get 'users/current', to: 'sessions#show'
        post 'rooms', to: 'room#create'
        get 'rooms', to: 'room#index'
        get 'rooms/:id', to: 'room#show'
      end

      post 'spotify/authenticate', to: 'spotify#authenticate'
      post 'spotify/refresh_token', to: 'spotify#refresh_token'

      mount ActionCable.server => '/cable'
    end

  end
end
