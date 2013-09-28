class AddCancelDateToSubscriber < ActiveRecord::Migration
  def change
  	add_column :subscribers, :cancel_date, :date
  end
end
