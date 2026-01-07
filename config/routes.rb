Rails.application.routes.draw do
  namespace :admin do
    get "settings", to: "settings#index", as: :settings
    post "settings/toggle_lifetime_offer", to: "settings#toggle_lifetime_offer", as: :toggle_lifetime_offer_settings
  end
  get "users/profile"
  get "users/update_profile"
  # Rails 8 built-in authentication routes
  resource :session
  resources :passwords, param: :token

  # Registration routes
  get "signup", to: "registrations#new", as: :new_registration
  post "signup", to: "registrations#create", as: :registration

  # Hotwire Native
  get "path-configuration", to: "hotwire_native#path_configuration", defaults: { format: :json }, as: :path_configuration

  # API routes for mobile apps
  namespace :api do
    namespace :v1 do
      resources :device_tokens, only: [:create, :destroy]
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # SEO routes
  get "sitemap.xml" => "sitemaps#index", defaults: { format: "xml" }, as: :sitemap

  # Public content pages
  get "privacy", to: "pages#privacy", as: :privacy
  get "terms", to: "pages#terms", as: :terms
  get "support", to: "pages#support", as: :support

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
      post :schedule_for_today
    end
    collection do
      post :update_order
    end
  end
  
  resources :focus_sessions, only: [:create, :show, :update] do
    member do
      post :end_session
      post :add_interruption
      post :start_timer
      post :pause_timer
      post :resume_timer
      post :stop_timer
    end
  end
  
  resources :rewards do
    member do
      post :redeem
    end
  end
  
  resources :achievements, only: [:index, :show]
  
  resources :feedbacks, only: [:new, :create, :index]

  # Subscription routes
  get 'pricing', to: 'pricing#index', as: :pricing
  resources :subscriptions, only: [:new, :create] do
    collection do
      get :success, to: 'subscriptions#success', as: :success
      get :manage, to: 'subscriptions#manage', as: :manage
      get :cancel, to: 'subscriptions#cancel', as: :cancel
      post :process_cancellation, to: 'subscriptions#process_cancellation', as: :process_cancellation
      post :reactivate, to: 'subscriptions#reactivate', as: :reactivate
      get :portal, to: 'subscriptions#portal', as: :portal
    end
  end

  # Stripe webhooks
  post 'webhooks/stripe', to: 'webhooks#stripe'

  get 'dashboard', to: 'dashboard#index'
  get 'profile', to: 'users#profile'
  patch 'profile', to: 'users#update_profile'
  get 'calendar', to: 'calendar#index', as: :calendar
  get 'sprites', to: 'sprites#index', as: :sprites
  get 'clear_cookies', to: 'home#clear_cookies', as: :clear_cookies
  get 'test_banner', to: 'home#test_banner', as: :test_banner
  get 'test_notifications', to: 'home#test_notifications', as: :test_notifications

  # Defines the root path route ("/")
  root "home#index"
end