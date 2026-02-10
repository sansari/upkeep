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

ActiveRecord::Schema[8.1].define(version: 2026_02_10_073735) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "areas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "icon"
    t.boolean "is_default", default: false, null: false
    t.string "name", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_areas_on_name", unique: true
  end

  create_table "equipment", force: :cascade do |t|
    t.bigint "area_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "manufacturer"
    t.string "model_number"
    t.string "name", null: false
    t.text "notes"
    t.date "purchase_date"
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_equipment_on_area_id"
  end

  create_table "maintenance_logs", force: :cascade do |t|
    t.datetime "completed_at", null: false
    t.datetime "created_at", null: false
    t.bigint "maintenance_task_id", null: false
    t.text "notes"
    t.datetime "updated_at", null: false
    t.index ["maintenance_task_id"], name: "index_maintenance_logs_on_maintenance_task_id"
  end

  create_table "maintenance_tasks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "equipment_id", null: false
    t.string "frequency_unit", null: false
    t.integer "frequency_value", null: false
    t.text "instructions"
    t.datetime "last_completed_at"
    t.string "name", null: false
    t.datetime "next_due_at"
    t.text "notes"
    t.string "priority", default: "medium", null: false
    t.datetime "updated_at", null: false
    t.index ["equipment_id"], name: "index_maintenance_tasks_on_equipment_id"
    t.index ["next_due_at"], name: "index_maintenance_tasks_on_next_due_at"
    t.index ["priority"], name: "index_maintenance_tasks_on_priority"
  end

  create_table "supplies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "maintenance_task_id", null: false
    t.string "name", null: false
    t.text "notes"
    t.string "purchase_url"
    t.integer "quantity_on_hand", default: 0, null: false
    t.integer "quantity_per_use", default: 1, null: false
    t.decimal "unit_price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["maintenance_task_id"], name: "index_supplies_on_maintenance_task_id"
  end

  add_foreign_key "equipment", "areas"
  add_foreign_key "maintenance_logs", "maintenance_tasks"
  add_foreign_key "maintenance_tasks", "equipment"
  add_foreign_key "supplies", "maintenance_tasks"
end
