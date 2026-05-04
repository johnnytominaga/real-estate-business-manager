# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_02_11_214308) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "areas", force: :cascade do |t|
    t.string "area"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "property_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_bookmarks_on_property_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "candidates", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone_country_code"
    t.string "phone_number"
    t.integer "position"
    t.text "presentation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "conversations", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lead_areas", force: :cascade do |t|
    t.bigint "area_id"
    t.bigint "lead_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_lead_areas_on_area_id"
    t.index ["lead_id"], name: "index_lead_areas_on_lead_id"
  end

  create_table "lead_locations", force: :cascade do |t|
    t.bigint "location_id"
    t.bigint "lead_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_lead_locations_on_lead_id"
    t.index ["location_id"], name: "index_lead_locations_on_location_id"
  end

  create_table "lead_phases", force: :cascade do |t|
    t.integer "lead_id"
    t.integer "phase_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comment"
  end

  create_table "lead_properties", force: :cascade do |t|
    t.bigint "property_id"
    t.bigint "lead_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.boolean "shared_with_lead", default: false
    t.boolean "liked_by_lead", default: false
    t.boolean "visited_by_lead", default: false
    t.datetime "visit_date"
    t.string "meeting_point"
    t.integer "proposal_amount"
    t.integer "premium_amount"
    t.integer "deposit_amount"
    t.integer "contract_amount"
    t.integer "deposit_for_bills"
    t.datetime "contract_start_date"
    t.datetime "contract_end_date"
    t.datetime "contract_signature_date"
    t.boolean "deposit_paid", default: false
    t.boolean "contract_signed", default: false
    t.boolean "commission_sorted", default: false
    t.boolean "vat_client", default: true
    t.boolean "vat_owner", default: true
    t.boolean "commission_paid", default: false
    t.index ["lead_id"], name: "index_lead_properties_on_lead_id"
    t.index ["property_id"], name: "index_lead_properties_on_property_id"
  end

  create_table "leads", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "email"
    t.integer "contract_type"
    t.integer "property_type"
    t.integer "bedrooms"
    t.integer "budget"
    t.text "description"
    t.datetime "check_in_date"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "no_of_people"
    t.string "nationality"
    t.boolean "deposit_paid"
    t.boolean "contract_signed"
    t.boolean "commission_paid"
    t.boolean "dropped"
    t.string "phone_country_code", default: "MT"
    t.boolean "information_collected"
    t.boolean "property_found"
    t.boolean "negotiation_completed"
    t.integer "contract_period"
    t.boolean "commission_sorted", default: false
    t.bigint "dropped_by_id"
    t.string "reason_for_dropping"
    t.boolean "pet_friendly"
    t.index ["dropped_by_id"], name: "index_leads_on_dropped_by_id"
    t.index ["user_id"], name: "index_leads_on_user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.bigint "area_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["area_id"], name: "index_locations_on_area_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.bigint "user_id"
    t.bigint "conversation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "content"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "owners", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.string "additional_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_country_code", default: "MT"
  end

  create_table "phases", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "owner_id"
    t.integer "bedrooms"
    t.integer "bathrooms"
    t.integer "kitchens"
    t.integer "property_type"
    t.integer "price"
    t.integer "premium"
    t.string "address"
    t.text "description"
    t.boolean "lift"
    t.boolean "ac"
    t.boolean "roof"
    t.integer "balconies"
    t.boolean "yard"
    t.boolean "seafront"
    t.boolean "seaview"
    t.boolean "swimming_pool"
    t.boolean "jacuzzi"
    t.boolean "unfurnished"
    t.integer "permit_class"
    t.integer "sqm"
    t.integer "office_rooms"
    t.integer "floor"
    t.boolean "deposit"
    t.boolean "electrics"
    t.text "obs"
    t.datetime "availability_date"
    t.boolean "pics"
    t.string "listed_by"
    t.integer "contract_type"
    t.float "latitude"
    t.float "longitude"
    t.boolean "bookable", default: true
    t.boolean "active"
    t.integer "payment_format"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "location_id"
    t.integer "area_id"
    t.integer "updated_by"
    t.string "flat_no", default: "1"
    t.integer "style"
    t.boolean "not_answering", default: false
    t.boolean "stop_calling", default: false
    t.integer "condition"
    t.integer "old_id"
    t.integer "created_by"
    t.integer "assigned_to"
    t.integer "photos_count"
    t.boolean "sold"
    t.boolean "pet_friendly"
    t.index ["owner_id", "bedrooms", "location_id", "contract_type", "property_type", "flat_no"], name: "unique_properties_index", unique: true
    t.index ["owner_id"], name: "index_properties_on_owner_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.boolean "enable_email", default: true
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_settings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.bigint "role_id"
    t.string "authentication_token", limit: 30
    t.string "nickname"
    t.boolean "is_active", default: true
    t.boolean "listing_rights", default: true
    t.integer "unread", default: 0
    t.string "personal_email"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookmarks", "properties"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "lead_areas", "areas"
  add_foreign_key "lead_areas", "leads"
  add_foreign_key "lead_locations", "leads"
  add_foreign_key "lead_locations", "locations"
  add_foreign_key "lead_properties", "leads"
  add_foreign_key "lead_properties", "properties"
  add_foreign_key "leads", "users"
  add_foreign_key "leads", "users", column: "dropped_by_id"
  add_foreign_key "locations", "areas"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "properties", "owners"
  add_foreign_key "settings", "users"
  add_foreign_key "users", "roles"
end
