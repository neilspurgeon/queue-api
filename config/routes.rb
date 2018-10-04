Rails.application.routes.draw do
  scope :api, defaults: {format: :json} do
    devise_for :users, :controllers => { :sessions => "v1/sessions" }

    namespace :v1 do
      devise_scope :user do
        get 'users/current', to: 'sessions#show'
      end
      post 'spotify/authenticate', to: 'spotify#authenticate'
      post 'spotify/refresh_token', to: 'spotify#refresh_token'
      mount ActionCable.server => '/cable'
    end

  end
end
