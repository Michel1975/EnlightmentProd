module Permissions
  class MerchantPermission < BasePermission
    
    def initialize(user, current_merchant_store)
      allow :dashboards, [:store_dashboard]
      allow :campaigns, [:index, :new, :create]
      allow :campaigns, [:show, :edit, :update, :destroy] do |campaign|
        campaign.merchant_store_id == current_merchant_store.id
      end
      allow :subscribers, [:index]
      allow :subscribers, [:destroy, :show, :prepare_single_message, :send_single_message] do |subscriber|
        subscriber.merchant_store_id == current_merchant_store.id 
      end

      allow :merchant_members, [:new, :create]

      allow :merchant_stores, [:edit, :show, :update, :active_subscription] do |store|
        store.id == current_merchant_store.id
      end

      allow :merchant_users, [:show, :edit, :update] do |merchant_user|
        merchant_user.merchant_store_id == current_merchant_store.id  
      end

      allow :offers, [:index, :new, :create]
      allow :offers, [:show, :edit, :update, :destroy] do |offer|
        offer.merchant_store_id == current_merchant_store.id
      end

      allow :welcome_offers, [:edit, :update, :show] do |welcome_offer|
        welcome_offer.merchant_store_id == current_merchant_store.id  
      end
    end

  end
end


