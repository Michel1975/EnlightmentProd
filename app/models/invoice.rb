class Invoice < ActiveRecord::Base
  attr_accessible :period_start, :period_end, :amount_ex_moms, :amount_incl_moms, :comment, :merchant_store_id 

  belongs_to :merchant_store

  validates :period_start, :period_end, :merchant_store_id, presence: true
  validates :amount_ex_moms, :amount_incl_moms, numericality: true
end
