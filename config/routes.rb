EnlightmentProd::Application.routes.draw do
  #get "password_resets/create"

  #get "password_resets/edit"

  #get "password_resets/update"

  root :to => "root#home"
  get "secret" => "root#secret", :as => "secret" 
  
  namespace :merchant do
    get "dashboard" => "dashboards#store_dashboard", :as => "dashboard"
    
    resources :subscribers, :only => [:index, :show, :destroy, :new] do
      get 'prepare_single_message', :on => :member
      post 'send_single_message', :on => :member
    end
    resources :offers 
    resources :welcome_offers
    resources :campaigns
    resources :merchant_users
    resources :merchant_members

    resources :merchant_stores do
      #Kunne også være en match-rute uden id idet vi altid viser merchant-store fra session storage.
      get 'active_subscription', :on => :member 
    end

  end

  namespace :shared do
    resources :members do
      #Invoked from merchant portal - layout valg skal tilpasses
      get 'new_manual_subscriber', :on => :member
      post 'create_manual_subscriber', :on => :member
    end
    resources :users
    resources :password_resets
    resources :merchant_sessions, :only => [:new, :create, :destroy]
    resources :member_sessions, :only => [:new, :create, :destroy]
    resources :member_users

    #Member session paths
    get "login_member" => "member_sessions#new", :as => "login_member"
    get "logout_member" => "member_sessions#destroy", :as => "logout_member"

    #MerchantUser session paths
    get "login_merchant" => "merchant_sessions#new", :as => "login_merchant"
    get 'logout_merchant',  to: "merchant_sessions#destroy", :as => "logout_merchant"

    #Member signup
    get "signup_member" => "member_users#new", :as => "signup_member"
  end

  namespace :admin do
  end
  
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
