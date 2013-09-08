class CreateCampaignMembers < ActiveRecord::Migration
  def change
    create_table :campaign_members do |t|
      t.integer :subscriber_id
      t.integer :campaign_id
      t.string :status

      t.timestamps
    end
    add_index :campaign_members, :subscriber_id
    add_index :campaign_members, :campaign_id
    add_index :campaign_members, [:subscriber_id, :campaign_id], unique: true
  end
end
