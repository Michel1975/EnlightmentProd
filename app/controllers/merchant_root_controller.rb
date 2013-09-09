class MerchantRootController < ApplicationController
	layout 'merchant'
	before_filter :require_login

	def home

	end
end
