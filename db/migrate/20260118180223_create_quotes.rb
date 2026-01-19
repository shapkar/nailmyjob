class CreateQuotes < ActiveRecord::Migration[8.1]
  def change
    create_table :quotes do |t|
      t.references :company, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.string :quote_number
      t.integer :status
      t.integer :template_type
      t.string :project_address
      t.string :project_city
      t.string :project_state
      t.string :project_zip_code
      t.integer :project_size
      t.decimal :total_range_low
      t.decimal :total_range_high
      t.decimal :approved_changes_total
      t.text :notes
      t.text :terms
      t.text :payment_terms
      t.string :timeline_estimate
      t.integer :valid_days
      t.string :client_view_token
      t.datetime :sent_at
      t.datetime :viewed_at
      t.datetime :accepted_at
      t.datetime :signed_at
      t.jsonb :signature_data

      t.timestamps
    end
    add_index :quotes, :quote_number, unique: true
    add_index :quotes, :client_view_token, unique: true
  end
end
