class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email_address
      t.string :password_digest
      
      t.references :role, null: false, foreign_key: true
      
      t.string "lastname"
      t.string "firstname"
      
      t.integer "isactivated", default: 1
      t.integer "isblocked", default: 0
      
      t.integer "mailtoken", default: 0
      t.string "mobile"
      t.text "secret"
      t.text "qrcodeurl"
      t.string "username", null: false
      t.string "userpic", default: "pix.png", null: false
      
      t.index ["email_address"], name: "index_users_on_email_address", unique: true
      t.index ["username"], name: "index_users_on_username", unique: true
      
      t.timestamps
    end
  end
end
