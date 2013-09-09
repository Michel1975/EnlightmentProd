class Feature < ActiveRecord::Base
  attr_accessible :description, :subscription_type_id, :title

  belongs_to :subscription_type
end
