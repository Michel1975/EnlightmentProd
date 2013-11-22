class AddMobileConfirmationCodeToMember < ActiveRecord::Migration
  def change
    add_column :members, :phone_confirmation_code, :integer
  end
end
