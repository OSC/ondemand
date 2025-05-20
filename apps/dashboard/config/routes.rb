# frozen_string_literal: true

require 'authz/app_developer_constraint'

Rails.application.routes.draw do
  if Configuration.can_access_projects?
    get 'projects/import' => 'projects#import', :as => 'project_import'
    post 'projects/import' => 'projects#import_save', :as => 'project_import_save'

    resources :projects do
      root 'projects#index'
      get '/jobs/:cluster/:jobid' => 'projects#job_details', :defaults => { :format => 'turbo_stream' }, :as => 'job_details'
      delete '/jobs/:cluster/:jobid' => 'projects#delete_job', :as => 'delete_job'
      post '/jobs/:cluster/:jobid/stop' => 'projects#stop_job', :as => 'stop_job'

      resources :launchers do
        post 'submit', on: :member
        post 'save', on: :member
      end
    end
  end

  # in production, if the user doesn't have access to the files app directory, we hide the routes
  if Configuration.can_access_files?
    constraints(->(request) { request.params[:fs].to_s.match?(%r{^(?!(edit|api))[^/]+$}) }) do
      get 'files/:fs(/*filepath)' => 'files#fs', :defaults => { :fs => 'fs', :format => 'html' }, :format => false,
          :as => :files
      put 'files/:fs/*filepath' => 'files#update', :format => false, :defaults => { :fs => 'fs', :format => 'json' }

      # TODO: deprecate these routes after updating OodAppkit to use the new routes above
      # backwards compatibility with the "api" routes that OodAppkit provides
      # and are used by File Editor and Job Composer
      get 'files/api/v1/:fs(/*filepath)' => 'files#fs', :defaults => { :fs => 'fs', :format => 'html' },
          :format => false
      put 'files/api/v1/:fs/*filepath' => 'files#update', :format => false,
          :defaults => { :fs => 'fs', :format => 'json' }
    end
    post 'files/upload/:fs' => 'files#upload', :defaults => { :fs => 'fs' } if Configuration.upload_enabled?

    get 'files', to: redirect("files/fs#{Dir.home}")
    get 'files/fs', to: redirect("files/fs#{Dir.home}")
    get 'frames/directory_frame' => 'files#directory_frame', as: 'directory_frame'
    
    resources :transfers, only: [:show, :create, :destroy]
  end

  if Configuration.can_access_file_editor?
    # App file editor
    get 'files/edit/:fs/*filepath' => 'files#edit', :defaults => { :fs => 'fs', :path => '/', :format => 'html' },
        :format => false
    get 'files/edit/:fs' => 'files#edit', :defaults => { :fs => 'fs', :path => '/', :format => 'html' },
        :format => false
  end

  namespace :batch_connect do
    resources :sessions, only: [:index, :destroy]
    post 'sessions/:id/cancel', to: 'sessions#cancel', as: 'cancel_session'
    scope '*token', constraints: { token: %r{((usr/[^/]+)|dev|sys)/[^/]+(/[^/]+)?} } do
      resources :settings, only: [:show, :destroy]
      resources :session_contexts, only: [:new, :create]
      get "session_contexts/edit_settings/:id", to: "session_contexts#edit_settings", as: 'edit_settings'
      post "session_contexts/save_settings", to: "session_contexts#save_settings", as: 'save_settings'

      root 'session_contexts#new'
    end
  end
  get 'errors/not_found'
  get 'errors/internal_server_error'
  get 'dashboard/index'
  get 'logout' => 'dashboard#logout'

  # analytics request appears in the access logs and google analytics
  get 'analytics/:type' => proc { [204, {}, ['']] }, :as => 'analytics'

  get 'apps/show/:name(/:type(/:owner))' => 'apps#show', :as => 'app', :defaults => { type: 'sys' }, :constraints => { owner: %r{[^/]+} }
  get 'apps/icon/:name(/:type(/:owner))' => 'apps#icon', :as => 'app_icon', :defaults => { type: 'sys' }, :constraints => { owner: %r{[^/]+} }
  get 'apps/index' => 'apps#index'

  get 'apps/restart' => 'apps#restart' if Configuration.app_sharing_enabled?

  root 'dashboard#index'

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

  # ActiveJobs which can be disabled in production
  if Configuration.can_access_activejobs?
    get '/activejobs' => 'active_jobs#index'
    get '/activejobs/json' => 'active_jobs#json', :defaults => { :format => 'json' }
    delete '/activejobs' => 'active_jobs#delete_job', :as => 'delete_job'
  end

  get '/system-status', to: 'system_status#index', as: 'system_status' if Configuration.can_access_system_status?

  post 'settings', :to => 'settings#update'

  # Experimental Feature
  # Allows widget partials to be rendered without any page furniture.
  # It can be use to extend OOD functionality.
  if Configuration.widget_partials_enabled?
    match '/widgets/*widget_path', to: 'widgets#show', via: [:get, :post], as: 'widgets'
  end

  # Support ticket routes
  if Configuration.support_ticket_enabled?
    get '/support', to: 'support_ticket#new'
    post '/support', to: 'support_ticket#create'
  end

  # Custom pages route
  get '/custom/:page_code', to: 'custom_pages#index', as: :custom_pages

  match '/404', :to => 'errors#not_found', :via => :all
  match '/500', :to => 'errors#internal_server_error', :via => :all

  get 'module_browser' => 'module_browser#index', :as => 'module_browser'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
