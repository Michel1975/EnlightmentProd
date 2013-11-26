module ApplicationHelper
	def b(value)
		value == true ? "Ja" : "Nej"
  	end

	def tooltip(text, title)
		#content_tag(:span, class: "help-button", data: { rel: "popover", trigger: "hover", placement: "right", content: text, title: title, original_title: title } )
		#content_tag("span", class: "help-button")
		#content_tag(:span, { :class => "help-button"} )
		#content_tag(:span, nil, class: '#', id: 'foo', data: {foo: 'bar'})
		content_tag(:span, nil, class: "help-button", style: "", data: { rel: "popover", trigger: "hover", placement: "right", content: text, title: title, original_title: title } ) do |variable|
		'?'
		end
	end

	def gender_danish(gender)
		return gender == "W" ? "Kvinde" : "Mand"
	end

	def empty_attribute_info(attribute)
		return attribute.blank? ? "Ikke oplyst" : attribute
	end

	#Helps determine active menu item
	def currentMenuItem(expected, controller, action)  		
  		return "class=active" if expected == (controller + "#" + action)
	end

	def current_merchant_store=(merchant_store)
		@current_merchant_store = merchant_store
	end

	#Note: We use find_by_id to avoid exeception being raised in case of empty search result
	def current_merchant_store
		@current_merchant_store ||= session[:current_merchant_store_id] &&
      		MerchantStore.find_by_id(session[:current_merchant_store_id])
	end

	def current_merchant_user=(merchant_user)
		@current_merchant_user = merchant_user
	end

	#Note: We use find_by_id to avoid exeception being raised in case of empty search result
	def current_merchant_user
		@current_merchant_user ||= session[:current_user_id] &&
      		MerchantUser.find_by_id(session[:current_user_id])
	end

	def current_member_user=(member_user)
		@current_member_user = member_user
	end

	#Note: We use find_by_id to avoid exeception being raised in case of empty search result
	def current_member_user
		@current_member_user ||= session[:current_user_id] &&
      		Member.find_by_id(session[:current_user_id])
	end

	def current_admin_user=(admin_user)
		@current_admin_user = admin_user
	end

	def current_admin_user
		@current_admin_user ||= session[:current_user_id] &&
      		BackendAdmin.find(session[:current_user_id])
	end

	def member_user?
    	return current_user && current_user.sub_type == 'Member' ? true : false
  	end

  	def merchant_user?
    	return current_user && current_user.sub_type == 'MerchantUser' ? true : false
  	end

  	def admin_user?
    	return current_user && current_user.sub_type == 'BackendAmin' ? true : false
  	end

	def store_session_variables(user)
		#Reset session variables on each login
		delete_session_variables
		session[:current_user_id] = user.sub_id
		session[:current_user_type] = user.sub_type
		if user.sub_type == "MerchantUser"
			session[:current_merchant_store_id] = MerchantUser.find(user.sub_id).merchant_store.id
		end
	end

	def delete_session_variables
		session[:current_merchant_store_id] = nil
		session[:current_user_id] = nil
		session[:current_user_type] = nil
		current_member_user = nil
		current_merchant_user = nil
		current_admin_user = nil
	end
end
