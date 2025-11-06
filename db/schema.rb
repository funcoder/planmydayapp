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

ActiveRecord::Schema[8.0].define(version: 2025_11_06_080555) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "achievements", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "description"
    t.string "badge_icon"
    t.string "badge_color"
    t.datetime "earned_at"
    t.integer "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_achievements_on_user_id"
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

  create_table "api_usages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "endpoint", null: false
    t.integer "count", default: 0, null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_api_usages_on_date"
    t.index ["user_id", "endpoint", "date"], name: "index_api_usages_on_user_id_and_endpoint_and_date", unique: true
    t.index ["user_id"], name: "index_api_usages_on_user_id"
  end

  create_table "brain_dumps", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "content"
    t.boolean "processed", default: false
    t.datetime "processed_at"
    t.string "tags", default: [], array: true
    t.string "status", default: "pending"
    t.string "voice_recording_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["processed"], name: "index_brain_dumps_on_processed"
    t.index ["status"], name: "index_brain_dumps_on_status"
    t.index ["user_id"], name: "index_brain_dumps_on_user_id"
  end

  create_table "cancellation_feedbacks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "reason"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_cancellation_feedbacks_on_user_id"
  end

  create_table "device_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.string "platform", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["platform"], name: "index_device_tokens_on_platform"
    t.index ["user_id", "token"], name: "index_device_tokens_on_user_id_and_token", unique: true
    t.index ["user_id"], name: "index_device_tokens_on_user_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "feedback_type", null: false
    t.string "subject", null: false
    t.text "message", null: false
    t.string "status", default: "new", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feedback_type"], name: "index_feedbacks_on_feedback_type"
    t.index ["status"], name: "index_feedbacks_on_status"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "focus_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "task_id", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer "duration"
    t.integer "interruptions"
    t.text "notes"
    t.integer "focus_quality"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "paused_at"
    t.integer "timer_duration", default: 1500
    t.string "timer_state", default: "stopped"
    t.integer "timer_remaining"
    t.integer "total_paused_duration", default: 0
    t.index ["task_id"], name: "index_focus_sessions_on_task_id"
    t.index ["user_id"], name: "index_focus_sessions_on_user_id"
  end

  create_table "rewards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "description"
    t.integer "points_required"
    t.string "icon"
    t.string "color"
    t.boolean "redeemed"
    t.datetime "redeemed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_rewards_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sprite_characters", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "unlock_condition"
    t.integer "unlock_value"
    t.string "sprite_type"
    t.string "css_class"
    t.string "rarity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "description"
    t.string "status", default: "pending"
    t.string "priority", default: "medium"
    t.date "due_date"
    t.date "scheduled_for"
    t.integer "position"
    t.bigint "brain_dump_id"
    t.integer "estimated_time"
    t.integer "actual_time"
    t.string "tags", default: [], array: true
    t.string "color", default: "#6366f1"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brain_dump_id"], name: "index_tasks_on_brain_dump_id"
    t.index ["scheduled_for"], name: "index_tasks_on_scheduled_for"
    t.index ["status"], name: "index_tasks_on_status"
    t.index ["user_id", "position"], name: "index_tasks_on_user_id_and_position"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "user_sprites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "sprite_character_id", null: false
    t.datetime "unlocked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sprite_character_id"], name: "index_user_sprites_on_sprite_character_id"
    t.index ["user_id"], name: "index_user_sprites_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.jsonb "adhd_profile", default: {}
    t.jsonb "preferences", default: {}
    t.integer "total_points", default: 0
    t.integer "current_streak", default: 0
    t.date "last_active_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "email_address"
    t.string "subscription_tier", default: "free", null: false
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id"
    t.string "subscription_status", default: "inactive"
    t.datetime "subscription_period_end"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id", unique: true
    t.index ["stripe_subscription_id"], name: "index_users_on_stripe_subscription_id"
    t.index ["subscription_status"], name: "index_users_on_subscription_status"
    t.index ["subscription_tier"], name: "index_users_on_subscription_tier"
  end

  add_foreign_key "achievements", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_usages", "users"
  add_foreign_key "brain_dumps", "users"
  add_foreign_key "cancellation_feedbacks", "users"
  add_foreign_key "device_tokens", "users"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "focus_sessions", "tasks"
  add_foreign_key "focus_sessions", "users"
  add_foreign_key "rewards", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "tasks", "brain_dumps"
  add_foreign_key "tasks", "users"
  add_foreign_key "user_sprites", "sprite_characters"
  add_foreign_key "user_sprites", "users"
end
