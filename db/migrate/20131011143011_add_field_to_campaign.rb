class AddFieldToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :campaign_members_count, :integer
  end
end
