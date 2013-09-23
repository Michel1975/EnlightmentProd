module Shared::SessionsHelper
	#Helper methods for merchant users
	def current_merchant_store=(merchant_store)
		@current_merchant_store = merchant_store
	end

	def current_merchant_store
		@current_merchant_store ||= session[:current_merchant_store_id] &&
      		MerchantStore.find(session[:current_merchant_store_id])
	end

	def store_session_variables(user)
		session[:current_merchant_store_id] = user.sub_id
	end

	def delete_session_variables
		session[:current_merchant_store_id] = nil
	end
end # End class
