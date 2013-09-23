class Merchant::MerchantRootController < Shared::BaseController
	layout 'merchant'
	before_filter :require_login

	def home

	end
end
