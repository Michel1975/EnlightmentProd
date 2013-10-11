class ChangePhoneNumberFromMember < ActiveRecord::Migration
  
  add_index :members, :phone, unique: true
end
