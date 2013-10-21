module Permissions
  def self.permission_for(user)
  	if user.nil?
      GuestPermission.new
    elsif user && user.sub_type == "MerchantUser"
      MerchantPermission.new(user)
    elsif user && user.sub_type == "BackendAdmin"
      AdminPermission.new(user)
    else
      MemberPermission.new(user)
    end
  end
end