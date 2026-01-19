class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :phone
      t.string :email
      t.string :license_number
      t.decimal :default_labor_markup
      t.decimal :default_material_markup
      t.text :default_terms
      t.text :default_payment_terms
      t.text :legal_boilerplate
      t.jsonb :settings

      t.timestamps
    end
  end
end
