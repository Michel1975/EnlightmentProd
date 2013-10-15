class Merchant::MerchantMembersController < Merchant::BaseController
	#If-override-from-base: layout "merchant", except: [:index]
	
	#To be used from merchant portal when manually creating new subscriber from scrath - more logic needed
	def new
		@member = Member.new
	end

	#To be used from merchant portal when manually creating new subscriber from scrath - more logic needed
	def create
		@member = Member.find_by_phone(SMSUtility::SMSFactory.convert_phone_number(params[:member][:phone]))
		if @member.nil?
			@member = Member.new(params[:member])
			@member.validation_mode = 'store'
			@member.origin = 'store'
			if !@member.save
				return render action: 'new'
			end
		end
		if current_merchant_store.subscribers.find_by_member_id(@member)
			flash.now[:alert] = t(:member_already_exists, :scope => [:business_validations, :merchant_member]) 
			render action: 'new'
		else
			current_merchant_store.subscribers.create!(start_date: Date.today, member_id: @member.id )
			flash[:success] = t(:member_added, :scope => [:business_validations, :merchant_member])
			redirect_to merchant_subscribers_path
		end
    end
end#end class
