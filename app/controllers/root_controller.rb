class RootController < ApplicationController
	#default layout application is used
	skip_before_filter :require_login, :only => [:home]

	def home

	end

	def secret
	end

end
