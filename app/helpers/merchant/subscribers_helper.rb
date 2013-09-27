module Merchant::SubscribersHelper

	def gender(param)
    	if param == "W"
      		return "Kvinde"
    	else
     		return "Mand"
    	end
  	end

end#end helper


