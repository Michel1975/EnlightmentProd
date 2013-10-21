module Permissions
  class MerchantPermission < BasePermission
    
    def initialize(user)
      allow_all
      #allow :users, [:new, :create, :edit, :update]
      #allow :sessions, [:new, :create, :destroy]
      #allow :topics, [:index, :show, :new, :create]
      #allow :topics, [:edit, :update] do |topic|
        #topic.user_id == user.id
      #end
    end

  end
end