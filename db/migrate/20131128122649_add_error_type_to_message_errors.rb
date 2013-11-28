class AddErrorTypeToMessageErrors < ActiveRecord::Migration
  def change
    add_column :message_errors, :error_type, :string
  end
end
