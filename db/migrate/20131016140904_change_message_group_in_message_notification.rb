class ChangeMessageGroupInMessageNotification < ActiveRecord::Migration
  change_column :message_notifications, :campaign_group_id, :string
end
