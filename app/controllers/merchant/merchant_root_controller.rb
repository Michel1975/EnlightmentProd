class Merchant::MerchantRootController < Merchant::BaseController
	before_filter :require_login #man skal være merchantuser
	layout :determine_layout
	
	def home

	end
end
