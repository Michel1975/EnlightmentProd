#encoding: utf-8
class Admin::CampaignsController < Admin::BaseController
	def scheduled
		logger.info "Loading Campaigns scheduled action"
		@search = false
		logger.debug "Search flag: #{@search.inspect}"
    	
    	@campaigns = Campaign.scheduled.page(params[:page]).per_page(15)
    	logger.debug "Scheduled campaigns attributes hash: #{@campaigns.inspect}"
	end

	def completed
		logger.info "Loading Campaigns completed action"
    	@campaigns = Campaign.completed.page(params[:page]).per_page(15)
    	logger.debug "Completed campaigns attributes hash: #{@campaigns.inspect}"
	end

	def search_campaigns
	    logger.info "Loading Campaigns search_campaigns action"
	    @from_date = params[:from_date]
	    logger.debug "Search parameter - from-date: #{@from_date.inspect}"
	    @to_date = params[:to_date]
	    logger.debug "Search parameter - to-date: #{@to_date.inspect}"
	    @status = params[:status]
	    logger.debug "Search parameter - status: #{@status.inspect}"
	    
	    @campaigns = Campaign.search(@from_date, @to_date, @status).page(params[:page]).per_page(15)
	    logger.debug "Campaigns attributes hash: #{@campaigns.inspect}"

	    @search = true
	    logger.debug "Search flag: #{@search.inspect}"

	    logger.debug "Loading active view with search result..."
	    render 'scheduled'
  	end

  	def show
	    logger.info "Loading Campaigns show action"
	    @campaign = current_resource
	    @campaign_members = @campaign.campaign_members.page(params[:page]).per_page(10)
	    logger.debug "Campaign attributes hash: #{@campaign.attributes.inspect}"
	    logger.debug "Campaign members attributes hash: #{@campaign_members.inspect}"
  	end

  	def destroy
    	logger.info "Loading Campaigns destroy action"
    	@campaign = current_resource
    	logger.debug "Campaign attributes hash: #{@campaign.attributes.inspect}"
    
    	gateway_delete_status = true

      if @campaign.status == "gateway_confirmed" 
        logger.debug "Campaign is confirmed by gateway. Need to cancel in sms gateway..."
        if SMSUtility::SMSFactory.cancelScheduledOfferReminder?(@campaign)
          logger.debug "Campaign is successfully deleted in SMS gateway"
        else
          gateway_delete_status = false
          logger.debug "Error: Campaign was NOT deleted in SMS gateway"
        end
      end

      if gateway_delete_status && @campaign.destroy
        logger.debug "Campaign successfully deleted"
        logger.debug "Updating eventhistory..."
        m_user = MerchantUser.find(current_user.sub_id)
        log_event_history_merchant_portal(current_merchant_store, "campaign-cancelled", "#{m_user.name} annullerede en kampagne")
        flash[:success] = t(:campaign_deleted, :scope => [:business_validations, :campaign])
        redirect_to scheduled_admin_campaigns_path
      else
        logger.debug "Error: Campaign NOT deleted due to unknown errors"
        logger.fatal "Error: Campaign NOT deleted due to unknown errors"
        flash[:error] = t(:campaign_delete_technical_error, :scope => [:business_validations, :campaign])
        redirect_to scheduled_admin_campaigns_path
      end
  end

  	private
    def current_resource
      @current_resource ||= Campaign.find(params[:id]) if params[:id]
    end


end
