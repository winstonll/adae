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

ActiveRecord::Schema.define(version: 20151117205733) do

  create_table "items", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "image"
    t.integer  "user_id"
    t.integer  "deposit"
    t.boolean  "rent2buy"
    t.string   "tags"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "address_line1"
    t.string   "city"
    t.string   "image"
    t.string   "phone_number"
    t.string   "postal_code"
    t.boolean  "phone_verified"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
