Rails.application.routes.draw do
  # Returns 200 if the app boots cleanly. Used by Compose and uptime checks.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :auth do
      get    "csrf",     to: "csrf#show"
      post   "register", to: "registrations#create"
      post   "login",    to: "sessions#create"
      delete "logout",   to: "sessions#destroy"
      post   "google",   to: "google#create"
      get    "me",       to: "current_user#show"
    end

    resources :conversations, only: [ :index, :show, :create, :update, :destroy ] do
      resources :messages, only: [ :index, :create ]
    end
  end

  # Declared before the Avo engine so it does not claim these paths.
  get    "admin/login"  => "admin/sessions#new",     as: :admin_login
  post   "admin/login"  => "admin/sessions#create"
  delete "admin/logout" => "admin/sessions#destroy", as: :admin_logout

  mount Avo::Engine, at: Avo.configuration.root_path
end
