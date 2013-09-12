class Feature < ActiveRecord::Base
  attr_accessible :title, :description

  belongs_to :subscription_type

  validates :title, :description, :subscription_type_id, presence: true
end
