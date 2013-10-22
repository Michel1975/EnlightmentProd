module Permissions
  def self.permission_for(user, current_merchant_store)
  	if user.nil?
      GuestPermission.new
    elsif user && user.sub_type == "MerchantUser"
      MerchantPermission.new(user, current_merchant_store)
    elsif user && user.sub_type == "BackendAdmin"
      AdminPermission.new(user)
    elsif user && user.sub_type == "Member"
      MemberPermission.new(user)
    end
  end
end