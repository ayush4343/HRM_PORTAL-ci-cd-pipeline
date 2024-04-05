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

ActiveRecord::Schema[7.1].define(version: 2024_04_05_065638) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "attendances", force: :cascade do |t|
    t.date "date"
    t.integer "status"
    t.integer "punch_type"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.datetime "punch_in_times", default: [], array: true
    t.datetime "punch_out_times", default: [], array: true
    t.string "total_time"
    t.string "gross_hours"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.bigint "user_id"
    t.bigint "organization_id"
    t.bigint "request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_comments_on_organization_id"
    t.index ["request_id"], name: "index_comments_on_request_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "concerns", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "department_id"
    t.index ["department_id"], name: "index_concerns_on_department_id"
  end

  create_table "department_roles", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "department_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_department_roles_on_department_id"
    t.index ["role_id"], name: "index_department_roles_on_role_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id", null: false
    t.index ["organization_id"], name: "index_departments_on_organization_id"
  end

  create_table "geofencings", force: :cascade do |t|
    t.string "latitude"
    t.string "longitude"
    t.integer "radius"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_geofencings_on_organization_id"
  end

  create_table "leave_requests", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.integer "leave_type"
    t.integer "user_ids", default: [], array: true
    t.string "reason"
    t.string "start_time"
    t.string "end_time"
    t.boolean "paid_leave"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.string "subject"
    t.string "message"
    t.boolean "is_read", default: false
    t.bigint "recipient_id"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notification_type"
    t.integer "parent_id"
    t.bigint "organization_id"
    t.index ["organization_id"], name: "index_notifications_on_organization_id"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "organization_otps", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.integer "verification_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_organization_otps_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "email"
    t.string "company_name"
    t.string "website"
    t.string "contact"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.boolean "activated", default: false
    t.boolean "password_updated", default: false
    t.boolean "email_verified_for_reset_password", default: false, null: false
    t.integer "device_type"
    t.string "device_token"
    t.string "owner_name"
    t.string "address"
    t.string "type"
  end

  create_table "organizations_public_holidays", id: false, force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "public_holiday_id", null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "public_holidays", force: :cascade do |t|
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "regularization_logs", force: :cascade do |t|
    t.bigint "regularization_id", null: false
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "punch_in_times", default: [], array: true
    t.datetime "punch_out_times", default: [], array: true
    t.index ["regularization_id"], name: "index_regularization_logs_on_regularization_id"
  end

  create_table "regularizations", force: :cascade do |t|
    t.time "reg_punch_in_times", default: [], array: true
    t.time "reg_punch_out_times", default: [], array: true
    t.integer "user_ids", default: [], array: true
    t.integer "status"
    t.text "reason"
    t.bigint "attendance_id"
    t.bigint "user_id"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "requested_by"
    t.string "action_by"
    t.string "comment"
    t.index ["attendance_id"], name: "index_regularizations_on_attendance_id"
    t.index ["user_id"], name: "index_regularizations_on_user_id"
  end

  create_table "requests", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "type_of_concern"
    t.bigint "department_id", null: false
    t.integer "concern_related"
    t.index ["department_id"], name: "index_requests_on_department_id"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "role_permissions", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "permission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id"
    t.index ["organization_id"], name: "index_roles_on_organization_id"
  end

  create_table "user_otps", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "verification_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id"
    t.index ["organization_id"], name: "index_user_otps_on_organization_id"
    t.index ["user_id"], name: "index_user_otps_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "device_type"
    t.string "device_token"
    t.bigint "organization_id"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "phone_number"
    t.integer "gender"
    t.boolean "mobile_verified_for_reset_password", default: false, null: false
    t.boolean "password_updated", default: false
    t.bigint "role_id"
    t.string "type"
    t.datetime "shift_start"
    t.datetime "shift_end"
    t.datetime "buffer_time"
    t.integer "shift_mode"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attendances", "users"
  add_foreign_key "comments", "organizations"
  add_foreign_key "comments", "requests"
  add_foreign_key "comments", "users"
  add_foreign_key "concerns", "departments"
  add_foreign_key "department_roles", "departments"
  add_foreign_key "department_roles", "roles"
  add_foreign_key "departments", "organizations"
  add_foreign_key "notifications", "organizations"
  add_foreign_key "organization_otps", "organizations"
  add_foreign_key "regularization_logs", "regularizations"
  add_foreign_key "requests", "departments"
  add_foreign_key "requests", "users"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "roles", "organizations"
  add_foreign_key "user_otps", "organizations"
  add_foreign_key "user_otps", "users"
  add_foreign_key "users", "roles"
end
