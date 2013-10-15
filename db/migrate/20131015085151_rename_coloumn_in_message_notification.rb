class RenameColoumnInMessageNotification < ActiveRecord::Migration
  def change
  	rename_column :message_notifications, :type, :notification_type
  end
  
end
