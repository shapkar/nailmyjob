class CreateChangeOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :change_orders do |t|
      t.references :quote, null: false, foreign_key: true
      t.references :line_item, null: true, foreign_key: true
      t.integer :co_number
      t.integer :status
      t.text :description
      t.decimal :amount
      t.integer :category
      t.boolean :delays_schedule
      t.integer :delay_days
      t.boolean :is_time_and_materials
      t.decimal :hourly_rate
      t.text :legal_boilerplate
      t.jsonb :signature_data
      t.string :signer_name
      t.string :signer_email
      t.string :signer_ip_address
      t.jsonb :signer_geolocation
      t.string :client_view_token
      t.datetime :sent_at
      t.datetime :signed_at

      t.timestamps
    end
    add_index :change_orders, :client_view_token, unique: true
  end
end
