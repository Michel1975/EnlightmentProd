class CampaignMember < ActiveRecord::Base
  attr_accessible :campaign_id, :status, :subscriber_id

  belongs_to :campaign
  belongs_to :subscriber
end
