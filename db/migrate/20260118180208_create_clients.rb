class CreateClients < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.text :notes
      t.string :magic_link_token
      t.datetime :magic_link_expires_at

      t.timestamps
    end
    add_index :clients, :magic_link_token, unique: true
  end
end
