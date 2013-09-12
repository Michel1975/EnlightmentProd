class AddTermsOfServiceToMembers < ActiveRecord::Migration
  def change
    add_column :members, :terms_of_service, :boolean, default:false
  end
end
