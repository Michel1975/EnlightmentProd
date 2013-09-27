module Shared::SessionsHelper
	#Helper methods for merchant users
	def current_merchant_store=(merchant_store)
		@current_merchant_store = merchant_store
	end

	def current_merchant_store
		@current_merchant_store ||= session[:current_merchant_store_id] &&
      		MerchantStore.find(session[:current_merchant_store_id])
	end

	def current_merchant_user
		@current_merchant_user ||= session[:current_merchant_user_id] &&
      		MerchantUser.find(session[:current_merchant_user_id])
	end

	def store_session_variables(user)
		session[:current_merchant_store_id] = MerchantUser.find(user.sub_id).merchant_store.id
		session[:current_merchant_user_id] = user.sub_id
		session[:current_merchant_user_type] = user.sub_type
	end

	def delete_session_variables
		session[:current_merchant_store_id] = nil
		session[:current_merchant_user_id] = nil
		session[:current_merchant_user_type] = nil
	end
end # End class
