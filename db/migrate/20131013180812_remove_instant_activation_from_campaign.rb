class RemoveInstantActivationFromCampaign < ActiveRecord::Migration
  def change
  	remove_column :campaigns, :instant_activation
  end

  
end
