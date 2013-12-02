class RemoveActiveFromSubscribers < ActiveRecord::Migration
  def change
  	remove_column :subscribers, :active
  end
end
