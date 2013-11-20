class RemoveStatusFieldsFromMember < ActiveRecord::Migration
  def change
  	remove_column :members, :status
  	remove_column :subscribers, :cancel_date
  end
  
end
