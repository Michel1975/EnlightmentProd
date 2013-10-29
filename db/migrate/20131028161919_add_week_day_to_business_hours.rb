class AddWeekDayToBusinessHours < ActiveRecord::Migration
  def change
    add_column :business_hours, :day_text, :string
    add_column :business_hours, :closed, :boolean, :default => false
  end
end
