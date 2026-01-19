# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_18_211947) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "change_orders", force: :cascade do |t|
    t.decimal "amount"
    t.integer "category"
    t.string "client_view_token"
    t.integer "co_number"
    t.datetime "created_at", null: false
    t.integer "delay_days"
    t.boolean "delays_schedule"
    t.text "description"
    t.decimal "hourly_rate"
    t.boolean "is_time_and_materials"
    t.bigint "job_id"
    t.text "legal_boilerplate"
    t.bigint "line_item_id"
    t.bigint "quote_id"
    t.datetime "sent_at"
    t.jsonb "signature_data"
    t.datetime "signed_at"
    t.string "signer_email"
    t.jsonb "signer_geolocation"
    t.string "signer_ip_address"
    t.string "signer_name"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["client_view_token"], name: "index_change_orders_on_client_view_token", unique: true
    t.index ["job_id"], name: "index_change_orders_on_job_id"
    t.index ["line_item_id"], name: "index_change_orders_on_line_item_id"
    t.index ["quote_id"], name: "index_change_orders_on_quote_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "magic_link_expires_at"
    t.string "magic_link_token"
    t.string "name"
    t.text "notes"
    t.string "phone"
    t.string "state"
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["company_id"], name: "index_clients_on_company_id"
    t.index ["magic_link_token"], name: "index_clients_on_magic_link_token", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.datetime "created_at", null: false
    t.decimal "default_labor_markup"
    t.decimal "default_material_markup"
    t.text "default_payment_terms"
    t.text "default_terms"
    t.string "email"
    t.text "legal_boilerplate"
    t.string "license_number"
    t.string "name"
    t.string "phone"
    t.jsonb "settings"
    t.string "state"
    t.datetime "updated_at", null: false
    t.string "zip_code"
  end

  create_table "jobs", force: :cascade do |t|
    t.date "actual_completion_date"
    t.decimal "change_orders_total", precision: 10, scale: 2, default: "0.0"
    t.bigint "client_id", null: false
    t.string "client_view_token"
    t.bigint "company_id", null: false
    t.decimal "contracted_amount_high", precision: 10, scale: 2
    t.decimal "contracted_amount_low", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.date "estimated_completion_date"
    t.string "job_number", null: false
    t.text "notes"
    t.string "project_address"
    t.string "project_city"
    t.string "project_state"
    t.string "project_zip_code"
    t.bigint "quote_id", null: false
    t.date "start_date"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["client_id"], name: "index_jobs_on_client_id"
    t.index ["client_view_token"], name: "index_jobs_on_client_view_token", unique: true
    t.index ["company_id"], name: "index_jobs_on_company_id"
    t.index ["job_number"], name: "index_jobs_on_job_number", unique: true
    t.index ["quote_id"], name: "index_jobs_on_quote_id"
    t.index ["status"], name: "index_jobs_on_status"
    t.index ["user_id"], name: "index_jobs_on_user_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.integer "category"
    t.datetime "created_at", null: false
    t.string "description"
    t.decimal "final_price"
    t.string "final_selection"
    t.text "internal_notes"
    t.boolean "is_allowance"
    t.boolean "is_range", default: false, null: false
    t.integer "quality_tier"
    t.bigint "quote_id", null: false
    t.decimal "range_high"
    t.decimal "range_low"
    t.integer "selection_status"
    t.integer "sort_order"
    t.decimal "suggested_range_high"
    t.decimal "suggested_range_low"
    t.datetime "updated_at", null: false
    t.index ["quote_id"], name: "index_line_items_on_quote_id"
  end

  create_table "quote_templates", force: :cascade do |t|
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.boolean "is_system", default: false
    t.jsonb "line_items_config", default: []
    t.string "name"
    t.integer "template_type"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_quote_templates_on_company_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.datetime "accepted_at"
    t.decimal "approved_changes_total"
    t.bigint "client_id", null: false
    t.string "client_view_token"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.text "notes"
    t.text "payment_terms"
    t.string "project_address"
    t.string "project_city"
    t.integer "project_size"
    t.string "project_state"
    t.string "project_zip_code"
    t.string "quote_number"
    t.datetime "sent_at"
    t.jsonb "signature_data"
    t.datetime "signed_at"
    t.integer "status"
    t.integer "template_type"
    t.text "terms"
    t.string "timeline_estimate"
    t.decimal "total_range_high"
    t.decimal "total_range_low"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "valid_days"
    t.datetime "viewed_at"
    t.index ["client_id"], name: "index_quotes_on_client_id"
    t.index ["client_view_token"], name: "index_quotes_on_client_view_token", unique: true
    t.index ["company_id"], name: "index_quotes_on_company_id"
    t.index ["quote_number"], name: "index_quotes_on_quote_number", unique: true
    t.index ["user_id"], name: "index_quotes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0
    t.jsonb "settings", default: {}
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "voice_sessions", force: :cascade do |t|
    t.bigint "change_order_id", null: false
    t.decimal "confidence_score"
    t.datetime "created_at", null: false
    t.integer "duration_seconds"
    t.jsonb "extracted_data"
    t.integer "purpose"
    t.bigint "quote_id", null: false
    t.integer "status"
    t.text "transcript"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["change_order_id"], name: "index_voice_sessions_on_change_order_id"
    t.index ["quote_id"], name: "index_voice_sessions_on_quote_id"
    t.index ["user_id"], name: "index_voice_sessions_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "change_orders", "jobs"
  add_foreign_key "change_orders", "line_items"
  add_foreign_key "change_orders", "quotes"
  add_foreign_key "clients", "companies"
  add_foreign_key "jobs", "clients"
  add_foreign_key "jobs", "companies"
  add_foreign_key "jobs", "quotes"
  add_foreign_key "jobs", "users"
  add_foreign_key "line_items", "quotes"
  add_foreign_key "quote_templates", "companies"
  add_foreign_key "quotes", "clients"
  add_foreign_key "quotes", "companies"
  add_foreign_key "quotes", "users"
  add_foreign_key "users", "companies"
  add_foreign_key "voice_sessions", "change_orders"
  add_foreign_key "voice_sessions", "quotes"
  add_foreign_key "voice_sessions", "users"
end
