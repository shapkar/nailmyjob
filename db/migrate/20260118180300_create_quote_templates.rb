class CreateQuoteTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :quote_templates do |t|
      t.string :name
      t.integer :template_type
      t.boolean :is_system, default: false
      t.references :company, null: true, foreign_key: true
      t.jsonb :line_items_config, default: []

      t.timestamps
    end
  end
end
