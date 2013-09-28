class AddTotalCostToCampaign < ActiveRecord::Migration
  def change
  	add_column :campaigns, :total_cost, :decimal
  end
end
