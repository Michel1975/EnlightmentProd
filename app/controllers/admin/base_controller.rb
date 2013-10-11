class Admin::BaseController < ApplicationController
	before_filter :admin_user
	layout 'admin'
end
