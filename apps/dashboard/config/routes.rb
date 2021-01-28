require "authz/app_developer_constraint"

Rails.application.routes.draw do
  namespace :batch_connect do
    resources :sessions, only: [:index, :destroy]
    scope "*token", constraints: { token: /((usr\/[^\/]+)|dev|sys)\/[^\/]+(\/[^\/]+)?/ } do
      resources :session_contexts, only: [:new, :create]
      root "session_contexts#new"
    end
  end
  get "errors/not_found"
  get "errors/internal_server_error"
  get "dashboard/index"
  get "logout" => "dashboard#logout"

  # analytics request appears in the access logs and google analytics
  get "analytics/:type" => proc { [204, {}, ['']] }, as: "analytics"


  get "apps/show/:name(/:type(/:owner))" => "apps#show", as: "app", defaults: { type: "sys" }
  get "apps/icon/:name(/:type(/:owner))" => "apps#icon", as: "app_icon", defaults: { type: "sys" }
  get "apps/index" => "apps#index"

  if Configuration.app_sharing_enabled?
    get "apps/restart" => "apps#restart"
    get "apps/featured" => "apps#featured"

    root "apps#featured"
  else
    root "dashboard#index"
  end

  # App administration
  scope 'admin/:type', constraints: Authz::AppDeveloperConstraint do
    resources :products, except: :destroy, param: :name, constraints: { type: /dev|usr/ } do
      nested do
        scope ':context' do
          resources :permissions, only: [:index, :new, :create, :destroy], param: :name
        end
      end
      member do
        patch 'cli/:cmd', to: 'products#cli', as: 'cli'
      end
      collection do
        get 'create_key'
        get 'new_from_git_remote'
        post 'create_from_git_remote'
      end
    end
  end

  # App file editor
  get "/edit/*path" => "file_editor#index", defaults: { :path => "/" , :format => 'html' }, format: false
  get "/edit" => "file_editor#index", :defaults => { :path => "/", :format => 'html' }, format: false
  get get "/file_editor" => "file_editor#index"

  # Errors
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all
end
