Rails.application.routes.draw do
  scope :api, defaults: {format: :json} do
    devise_for :users, :controllers => { :sessions => "v1/sessions" }

    namespace :v1 do
      devise_scope :user do
        get 'users/current', to: 'sessions#show'
      end
      resources :examples
    end

  end
end
