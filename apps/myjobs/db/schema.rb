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

ActiveRecord::Schema[7.0].define(version: 2016_06_01_203013) do
  create_table "jobs", force: :cascade do |t|
    t.integer "workflow_id"
    t.string "status"
    t.text "job_cache"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["workflow_id"], name: "index_jobs_on_workflow_id"
  end

  create_table "json_stores", force: :cascade do |t|
    t.text "json_attrs"
    t.string "type"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["type"], name: "index_json_stores_on_type"
  end

  create_table "workflows", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "job_attrs"
    t.string "name"
    t.string "batch_host"
    t.string "staged_dir"
    t.string "script_name"
  end

end
