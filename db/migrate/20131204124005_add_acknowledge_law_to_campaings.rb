class AddAcknowledgeLawToCampaings < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :acknowledgement, :boolean, :default => false
  end

  def self.down
  	remove_column :campaigns, :acknowledgement
  end
end
