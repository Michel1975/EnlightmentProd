class Invoice < ActiveRecord::Base
  attr_accessible :amount_ex_moms, :amount_incl_moms, :comment, :merchant_store_id, :period_end, :period_start

  belongs_to :merchant_store
end
