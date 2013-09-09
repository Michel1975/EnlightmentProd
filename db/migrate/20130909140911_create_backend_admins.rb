class CreateBackendAdmins < ActiveRecord::Migration
  def change
    create_table :backend_admins do |t|
      t.string :name
      t.string :role
      t.boolean :admin, default: true

      t.timestamps
    end
  end
end
