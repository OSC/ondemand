# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160601203013) do

  create_table "jobs", force: :cascade do |t|
    t.integer  "workflow_id"
    t.string   "status"
    t.text     "job_cache"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "jobs", ["workflow_id"], name: "index_jobs_on_workflow_id"

  create_table "json_stores", force: :cascade do |t|
    t.text     "json_attrs"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "json_stores", ["type"], name: "index_json_stores_on_type"

  create_table "workflows", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "job_attrs"
    t.string   "name"
    t.string   "batch_host"
    t.string   "staged_dir"
    t.string   "script_name"
  end

end
