class CreateMerchantUsers < ActiveRecord::Migration
  def change
    create_table :merchant_users do |t|
      t.string :name
      t.string :role
      t.boolean :admin, default: true

      t.timestamps
    end
  end
end
