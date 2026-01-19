# frozen_string_literal: true

class CreateJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :jobs do |t|
      # Associations
      t.references :quote, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      # Job identification
      t.string :job_number, null: false
      t.integer :status, default: 0, null: false

      # Project details (can differ from quote if scope changes)
      t.string :project_address
      t.string :project_city
      t.string :project_state
      t.string :project_zip_code

      # Financial tracking
      t.decimal :contracted_amount_low, precision: 10, scale: 2
      t.decimal :contracted_amount_high, precision: 10, scale: 2
      t.decimal :change_orders_total, precision: 10, scale: 2, default: 0

      # Timeline
      t.date :start_date
      t.date :estimated_completion_date
      t.date :actual_completion_date

      # Client portal access
      t.string :client_view_token

      # Notes
      t.text :notes

      t.timestamps
    end

    add_index :jobs, :job_number, unique: true
    add_index :jobs, :client_view_token, unique: true
    add_index :jobs, :status
  end
end
