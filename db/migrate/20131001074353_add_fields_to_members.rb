class AddFieldsToMembers < ActiveRecord::Migration
  def change
    add_column :members, :complete, :boolean, default: false
    add_column :members, :origin, :string
  end
end
