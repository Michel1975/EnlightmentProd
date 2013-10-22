module Permissions
  class MemberPermission < BasePermission
    def initialize(user)
      allow :member_users, [:show, :edit, :update, :destroy] do |member|
      	#Member users can only see, edit and destroy their own profiles.
      	member.id == user.sub_id	
      end

      allow :member_subscribers, [:subscribe, :unsubscribe] do |member|
      	member.id == user.sub_id
      end
      
    end
  end
end