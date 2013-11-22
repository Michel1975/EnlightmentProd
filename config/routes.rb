EnlightmentProd::Application.routes.draw do
  get "message_errors/index"

  #Common frontend paths
  root :to => "root#home"

  #Search from home tab
  match '/search_stores',  to: 'root#search_stores', via: :get, :as => "search_stores"

  #Handle incoming messages from customers
  match '/contact',  to: 'messages#contact', via: :get, :as => "contact"
  match '/send_message',  to: 'messages#send_message', via: :post, :as => "send_message"

  match '/merchant_info', to: 'root#merchant_info'
  #match '/contact', to: 'root#contact'
  #get "favorites" => "member_subscribers#favorites", :as => "favorites"
  match '/favorites/:id', to: 'member_users#favorites', :as => "favorites"
  get "terms_conditions" => "member_users#terms_conditions", :as => "terms_conditions"

  #Frontend resources
  resources :member_users do
    get 'send_mobile_confirmation_with_sms', :on => :member 
    post 'confirm_mobile_sms_code', :on => :member 
    get 'resend_email_confirmation', :on => :member
  end

  #Member signup
  get "new_member" => "member_users#new", :as => "new_member"

  #Member joining specific merchantstore on Map
  match '/display_store/:id',  to: 'root#show_merchant_store', :as => "display_store"
  #Subscribe + unsubscribe via Google Maps
  match '/signup_member',  to: 'member_subscribers#subscribe', :as => "signup_member", via: :post
  match '/unsubscribe_member/:id',  to: 'member_subscribers#unsubscribe', :as => "unsubscribe_member", via: :delete
  #Unsubscribe via favorite list in frontend
  match '/unsubscribe_member_table/:id',  to: 'member_subscribers#unsubscribe_member_table', :as => "unsubscribe_member_table", via: :delete

  #SMS opt-out from sms-link
  match '/stop_sms_confirm',  to: 'root#stop_sms_subscription_view', via: :get, :as => "stop_sms_confirm"
  match '/stop_sms_save',  to: 'root#stop_sms_subscription_update', via: :post, :as => "stop_sms_save"

  #Complete profile on web after signing up in store
  match '/edit_sms_profile',  to: 'member_users#complete_sms_profile', via: :get
  match '/update_sms_profile/:id', to: 'member_users#update_sms_profile', via: :put, :as => "update_sms_profile"

  #Confirm email
  match '/confirm_email', to: 'member_users#confirm_email', via: :get
  
  namespace :merchant do
    #Callback sms-handling
    match '/processMessage',  to: 'sms_handler#processMessage', via: :get
    match '/callbackMessage',  to: 'sms_handler#callbackMessage', via: :get
    get "dashboard" => "dashboards#store_dashboard", :as => "dashboard"
    
    resources :subscribers, :only => [:index, :show, :destroy, :new] do
      get 'prepare_single_message', :on => :member
      post 'send_single_message', :on => :member
    end
    
    resources :offers  do
      get 'active', :on => :collection
      get 'archived', :on => :collection
    end

    resources :welcome_offers
    
    resources :campaigns do
      get 'active', :on => :collection
      get 'finished', :on => :collection
      post 'send_test_message', :on => :member
    end

    resources :merchant_users
    resources :merchant_members, :only => [:new, :create]

    resources :merchant_stores do
      #Kunne også være en match-rute uden id idet vi altid viser merchant-store fra session storage.
      get 'active_subscription', :on => :member 
      get 'sms_qrcode', :on => :member 
    end

  end#End namespace :merchant

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
    resources :backend_admin_sessions, :only => [:new, :create, :destroy]

    #Member session paths
    get "login_member" => "member_sessions#new", :as => "login_member"
    get "logout_member" => "member_sessions#destroy", :as => "logout_member"

    #MerchantUser session paths
    get "login_merchant" => "merchant_sessions#new", :as => "login_merchant"
    get 'logout_merchant',  to: "merchant_sessions#destroy", :as => "logout_merchant"

    #BackendAdmin session paths
    get "login_admin" => "backend_admin_sessions#new", :as => "login_admin"
    get 'logout_admin',  to: "backend_admin_sessions#destroy", :as => "logout_admin"

    #old:Password resets routes
    #get "password_resets/create"
    #get "password_resets/edit"
    #get "password_resets/update"
  end#End namespace :shared

  namespace :admin do
    resources :backend_admins

    resources :merchant_stores do
      get 'active', :on => :collection
      get 'inactive', :on => :collection 
      get 'search_stores', :on => :collection
      get 'login_as', :on => :member
    end

    resources :campaigns do
      get 'scheduled', :on => :collection
      get 'completed', :on => :collection 
      get 'search_campaigns', :on => :collection
    end
    
    resources :members do
      get 'search_members', :on => :collection
      get 'resend_email_confirmation', :on => :member
      get 'send_mobile_confirmation_with_sms', :on => :member 
    end
    
    match 'remove_subscriber/:id' => "members#remove_subscriber", :as => "remove_subscriber"

    get "dashboard" => "dashboards#overview", :as => "dashboard"
    get "message_status" => "message_notifications#index", :as => "message_status"
    get "message_error" => "message_errors#index", :as => "message_error"

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
