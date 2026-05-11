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

ActiveRecord::Schema[8.1].define(version: 2026_05_11_034435) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.integer "alertstocks", default: 0
    t.string "category", limit: 255
    t.bigint "category_id", null: false
    t.decimal "costprice", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.integer "criticalstocks", default: 0
    t.string "descriptions", limit: 100
    t.string "productpicture"
    t.integer "qty", default: 0
    t.decimal "saleprice", precision: 10, scale: 2, default: "0.0"
    t.decimal "sellprice", precision: 10, scale: 2, default: "0.0"
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "sales", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "salesamount", precision: 10, scale: 2
    t.datetime "salesdate"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address"
    t.string "firstname"
    t.integer "isactivated", default: 1
    t.integer "isblocked", default: 0
    t.string "lastname"
    t.integer "mailtoken", default: 0
    t.string "mobile"
    t.string "password_digest"
    t.text "qrcodeurl"
    t.bigint "role_id", null: false
    t.text "secret"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.string "userpic", default: "pix.png", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "products", "categories"
  add_foreign_key "users", "roles"
end
