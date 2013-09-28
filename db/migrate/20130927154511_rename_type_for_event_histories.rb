class RenameTypeForEventHistories < ActiveRecord::Migration
  def change
  	rename_column :event_histories, :type, :event_type
  end
  
end
