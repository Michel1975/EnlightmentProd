class AddPhoneToSubscriberHistories < ActiveRecord::Migration
  def change
    add_column :subscriber_histories, :member_phone, :string
  end
end
