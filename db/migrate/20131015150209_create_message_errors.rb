class CreateMessageErrors < ActiveRecord::Migration
  def change
    create_table :message_errors do |t|
      t.string :name
      t.string :recipient

      t.timestamps
    end
  end
end
