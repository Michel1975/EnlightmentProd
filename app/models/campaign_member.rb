class CampaignMember < ActiveRecord::Base
  attr_accessible :campaign_id, :status, :subscriber_id
end
