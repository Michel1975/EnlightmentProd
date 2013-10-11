class RemoveColumnFromMessageNotifications < ActiveRecord::Migration
  def change
    remove_column :message_notifications, :message_group_id
  end
end
