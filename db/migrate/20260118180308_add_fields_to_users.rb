class AddFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :company, null: true, foreign_key: true
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :role, :integer, default: 0
    add_column :users, :settings, :jsonb, default: {}
  end
end
