class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :name
      t.string :phone
      t.string :postal_code
      t.string :gender
      t.date :birthday

      t.timestamps
    end
  end
end
