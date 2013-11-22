class AddStatusFieldsToMember < ActiveRecord::Migration
  def change
    add_column :members, :email_confirmed, :boolean, :default => false
    add_column :members, :phone_confirmed, :boolean, :default => false
  end
end
