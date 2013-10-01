class Merchant::BaseController < ApplicationController
	before_filter :merchant_user
	layout 'merchant'
end
