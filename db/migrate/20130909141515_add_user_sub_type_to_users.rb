class AddUserSubTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sub_id, :integer
    add_column :users, :sub_type, :string
    add_index :users, :sub_id
    add_index :users, :sub_type
    add_index :users, [:sub_id, :sub_type], unique: true
  end
  	
end
