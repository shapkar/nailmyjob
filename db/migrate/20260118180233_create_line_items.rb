class CreateLineItems < ActiveRecord::Migration[8.1]
  def change
    create_table :line_items do |t|
      t.references :quote, null: false, foreign_key: true
      t.integer :category
      t.string :description
      t.integer :quality_tier
      t.boolean :is_allowance
      t.decimal :range_low
      t.decimal :range_high
      t.decimal :suggested_range_low
      t.decimal :suggested_range_high
      t.string :final_selection
      t.decimal :final_price
      t.integer :selection_status
      t.text :internal_notes
      t.integer :sort_order

      t.timestamps
    end
  end
end
