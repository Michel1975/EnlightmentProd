module Permissions
  class MemberPermission < BasePermission
    def initialize(user)
      #allow :member_users, [:test_action]
      allow :member_users, [:show, :edit, :update, :destroy, :favorites, :resend_email_confirmation, :send_mobile_confirmation_with_sms, :confirm_mobile_sms_code] do |member|
      	#Member users can only see, edit and destroy their own profiles.
      	member.id == user.sub_id	
      end
      allow :member_subscribers, [:subscribe]
      allow :member_subscribers, [:unsubscribe, :unsubscribe_member_table] do |subscriber|
        subscriber.member.id == user.sub_id
      end
      
    end
  end
end