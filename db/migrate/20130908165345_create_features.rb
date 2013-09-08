class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string :title
      t.text :description
      t.integer :subscription_type_id

      t.timestamps
    end
    add_index :features, :subscription_type_id
  end
end
