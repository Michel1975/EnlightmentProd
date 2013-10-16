class ChangeFieldOnMessageError < ActiveRecord::Migration
  rename_column :message_errors, :name, :text
end
