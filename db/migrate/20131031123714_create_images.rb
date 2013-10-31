class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :imageable_type
      t.integer :imageable_id
      t.string :picture
      t.integer :size

      t.timestamps
    end
  end
end
