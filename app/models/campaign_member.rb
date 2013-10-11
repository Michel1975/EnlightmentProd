class CampaignMember < ActiveRecord::Base
  attr_accessible :status, :subscriber_id

  belongs_to :campaign
  belongs_to :subscriber

  validates :subscriber_id, :campaign_id, presence: true
  validates :status, :inclusion => { :in => %w(new not-received received)}
end
