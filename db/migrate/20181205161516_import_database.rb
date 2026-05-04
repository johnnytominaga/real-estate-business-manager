class ImportDatabase < ActiveRecord::Migration[5.2]
  create_table "areas", force: :cascade do |t|
    t.string "area"
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

  create_table "lead_properties", force: :cascade do |t|
    t.bigint "property_id"
    t.bigint "lead_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_leads_on_user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.bigint "area_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_locations_on_area_id"
  end

  create_table "owners", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.string "additional_info"
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
    t.index ["owner_id", "bedrooms", "location_id", "contract_type", "property_type", "flat_no"], name: "unique_properties_index", unique: true
    t.index ["owner_id"], name: "index_properties_on_owner_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "lead_areas", "areas"
  add_foreign_key "lead_areas", "leads"
  add_foreign_key "lead_locations", "leads"
  add_foreign_key "lead_locations", "locations"
  add_foreign_key "lead_properties", "leads"
  add_foreign_key "lead_properties", "properties"
  add_foreign_key "leads", "users"
  add_foreign_key "locations", "areas"
  add_foreign_key "properties", "owners"
  add_foreign_key "users", "roles"
end
