Rails.application.routes.draw do
  # Rails 8 built-in authentication routes
  resource :session
  resources :passwords, param: :token
  
  # Registration routes
  get "signup", to: "registrations#new", as: :new_registration
  post "signup", to: "registrations#create", as: :registration
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # App routes
  resources :brain_dumps do
    member do
      post :process_dump
      post :archive
    end
  end
  
  resources :tasks do
    member do
      post :complete
      post :start
      post :rollover
    end
    collection do
      post :update_order
    end
  end
  
  resources :focus_sessions, only: [:create, :update] do
    member do
      post :end_session
      post :add_interruption
    end
  end
  
  resources :rewards do
    member do
      post :redeem
    end
  end
  
  resources :achievements, only: [:index, :show]
  
  get 'dashboard', to: 'dashboard#index'
  get 'profile', to: 'users#profile'
  patch 'profile', to: 'users#update_profile'

  # Defines the root path route ("/")
  root "home#index"
end