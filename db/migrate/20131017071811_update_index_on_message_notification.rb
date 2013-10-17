class UpdateIndexOnMessageNotification < ActiveRecord::Migration
  def change
  	remove_index :message_notifications, :campaign_group_id
  	
  end
end
