class AddCampaignIdToMessageNotifications < ActiveRecord::Migration
  def change
    add_column :message_notifications, :campaign_group_id, :integer
  end
end
