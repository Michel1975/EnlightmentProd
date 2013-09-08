class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.date :period_start
      t.date :period_end
      t.decimal :amount_ex_moms
      t.decimal :amount_incl_moms
      t.text :comment
      t.integer :merchant_store_id

      t.timestamps
    end
    add_index :invoices, :merchant_store_id
  end
end
