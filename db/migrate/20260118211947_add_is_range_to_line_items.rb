class AddIsRangeToLineItems < ActiveRecord::Migration[8.1]
  def change
    add_column :line_items, :is_range, :boolean, default: false, null: false

    # Set existing allowance items to use range by default
    reversible do |dir|
      dir.up do
        execute "UPDATE line_items SET is_range = true WHERE is_allowance = true"
      end
    end
  end
end
