class AddindexToMessageNotification < ActiveRecord::Migration
  add_index :message_notifications, :campaign_group_id
end
