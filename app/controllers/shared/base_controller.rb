class Shared::BaseController < ApplicationController
	#No need to authorize shared ressources
	skip_before_filter :authorize
end
