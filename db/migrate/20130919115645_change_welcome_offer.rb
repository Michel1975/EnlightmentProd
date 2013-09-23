class ChangeWelcomeOffer < ActiveRecord::Migration
  def change
 	change_column :welcome_offers, :active, :boolean, default: false
  end
end
