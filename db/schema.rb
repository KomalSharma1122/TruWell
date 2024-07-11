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

ActiveRecord::Schema[7.1].define(version: 2024_05_09_085812) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.bigint "time_slot_id", null: false
    t.bigint "patient_id", null: false
    t.bigint "doctor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.datetime "start_time"
    t.datetime "end_time"
    t.index ["doctor_id"], name: "index_appointments_on_doctor_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["time_slot_id"], name: "index_appointments_on_time_slot_id"
  end

  create_table "chat_rooms", force: :cascade do |t|
    t.string "name"
    t.bigint "doctor_id", null: false
    t.bigint "patient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.index ["doctor_id"], name: "index_chat_rooms_on_doctor_id"
    t.index ["patient_id"], name: "index_chat_rooms_on_patient_id"
  end

  create_table "create_hospitals", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "pincode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_create_hospitals_on_user_id"
  end

  create_table "doctor_availabilities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "duration"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "for_date"
    t.datetime "start_time"
    t.datetime "end_time"
    t.index ["user_id"], name: "index_doctor_availabilities_on_user_id"
  end

  create_table "doctor_informations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "language"
    t.string "specialization"
    t.string "about"
    t.integer "charges"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_doctor_informations_on_user_id"
  end

  create_table "emergency_contact_details", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.string "phone_no"
    t.string "relation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_emergency_contact_details_on_user_id"
  end

  create_table "hospitals", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "pincode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_hospitals_on_user_id"
  end

  create_table "medical_histories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "disease_name"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.index ["user_id"], name: "index_medical_histories_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.bigint "sender_id", null: false
    t.bigint "receiver_id", null: false
    t.bigint "chat_room_id", null: false
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_room_id"], name: "index_messages_on_chat_room_id"
    t.index ["receiver_id"], name: "index_messages_on_receiver_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "prescriptions", force: :cascade do |t|
    t.bigint "appointment_id", null: false
    t.string "title"
    t.string "prescription_type"
    t.integer "dosage"
    t.integer "quantity"
    t.string "medicine"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "instructions"
    t.index ["appointment_id"], name: "index_prescriptions_on_appointment_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "time_slots", force: :cascade do |t|
    t.bigint "doctor_availability_id", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "status"
    t.index ["doctor_availability_id"], name: "index_time_slots_on_doctor_availability_id"
  end

  create_table "user_addresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "line1"
    t.string "line2"
    t.string "city"
    t.integer "pincode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_addresses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone_no"
    t.string "password"
    t.date "dob"
    t.integer "gender"
    t.integer "status"
    t.string "password_digest"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "profile_pic_file_name"
    t.string "profile_pic_content_type"
    t.bigint "profile_pic_file_size"
    t.datetime "profile_pic_updated_at"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "appointments", "time_slots"
  add_foreign_key "appointments", "users", column: "doctor_id"
  add_foreign_key "appointments", "users", column: "patient_id"
  add_foreign_key "chat_rooms", "users", column: "doctor_id"
  add_foreign_key "chat_rooms", "users", column: "patient_id"
  add_foreign_key "create_hospitals", "users"
  add_foreign_key "doctor_availabilities", "users"
  add_foreign_key "doctor_informations", "users"
  add_foreign_key "emergency_contact_details", "users"
  add_foreign_key "hospitals", "users"
  add_foreign_key "medical_histories", "users"
  add_foreign_key "messages", "chat_rooms"
  add_foreign_key "messages", "users", column: "receiver_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "prescriptions", "appointments"
  add_foreign_key "time_slots", "doctor_availabilities"
  add_foreign_key "user_addresses", "users"
end
