class CampaignMember < ActiveRecord::Base
  attr_accessible :status, :subscriber_id

  belongs_to :campaign, counter_cache: true
  belongs_to :subscriber

  validates :subscriber_id, :campaign_id, presence: true
  validates :status, :inclusion => { :in => %w(new not-received received)}

  before_save :set_default_status
  
  #Default status value is set to new
  def set_default_status
  	self.status ||= 'new'
  end

end#end class
