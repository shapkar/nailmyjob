class CreateVoiceSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :voice_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :quote, null: false, foreign_key: true
      t.references :change_order, null: false, foreign_key: true
      t.integer :purpose
      t.text :transcript
      t.jsonb :extracted_data
      t.decimal :confidence_score
      t.integer :duration_seconds
      t.integer :status

      t.timestamps
    end
  end
end
