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
	    logger.info "Loading campaign show action"
	    @campaign = current_resource
	    @campaign_members = @campaign.campaign_members.page(params[:page]).per_page(10)
	    logger.debug "Campaign attributes hash: #{@campaign.attributes.inspect}"
	    logger.debug "Campaign members attributes hash: #{@campaign_members.inspect}"
  	end

  	private
    def current_resource
      @current_resource ||= Campaign.find(params[:id]) if params[:id]
    end


end
