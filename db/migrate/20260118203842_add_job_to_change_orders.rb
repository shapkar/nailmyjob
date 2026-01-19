# frozen_string_literal: true

class AddJobToChangeOrders < ActiveRecord::Migration[8.1]
  def change
    # Add job_id to change_orders (nullable initially for migration)
    add_reference :change_orders, :job, foreign_key: true

    # We'll keep quote_id for now as optional (for historical reference)
    # and make job_id required after data migration
    change_column_null :change_orders, :quote_id, true
  end
end
