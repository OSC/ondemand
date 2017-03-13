Rails.application.routes.draw do
  get "errors/not_found"
  get "errors/internal_server_error"
  get "dashboard/index"
  get "logout" => "dashboard#logout"


  get "apps/show/:name(/:type(/:owner))" => "apps#show", as: "app", defaults: { type: "sys" }
  get "apps/icon/:name(/:type(/:owner))" => "apps#icon", as: "app_icon", defaults: { type: "sys" }

  #FIXME: undo when ready to deploy app sharing to production, remove?
  if ENV['OOD_APP_SHARING'].present?
    # TODO:
    # is there a cleaner approach to this? an app should be a resource
    get "apps(/index(/:type(/:owner)))" => "apps#index", as: "apps", defaults: { type: "usr" }
    get "apps/restart" => "apps#restart"

    root "apps#index", defaults: { type: "usr" }

    # App administration
    scope 'admin/:type' do
      resources :products, param: :name, constraints: { type: /dev|usr/ } do
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
          get 'new_from_rails_template'
          post 'create_from_git_remote'
          post 'create_from_rails_template'
        end
      end
    end
  else
    root "dashboard#index"
  end

  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

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
