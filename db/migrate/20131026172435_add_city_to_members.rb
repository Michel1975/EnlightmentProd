class AddCityToMembers < ActiveRecord::Migration
  def change
    add_column :members, :city, :string
  end
end
