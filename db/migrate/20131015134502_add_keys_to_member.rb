class AddKeysToMember < ActiveRecord::Migration
  def change
    add_column :members, :access_key, :string
  end
end
