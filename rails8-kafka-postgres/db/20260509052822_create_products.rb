class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :descriptions, null: false # Changed to singular
      t.references :category, null: false, foreign_key: true # This handles category_id
      
      t.integer :qty, default: 0
      t.string :unit
      
      # Added scale: 2 for currency
      t.decimal :costprice, precision: 10, scale: 2, default: 0
      t.decimal :sellprice, precision: 10, scale: 2, default: 0
      t.decimal :saleprice, precision: 10, scale: 2, default: 0
      
      t.integer :alertstocks, default: 0
      t.integer :criticalstocks, default: 0
      t.string :productpicture
      
      t.index :description, unique: true
      t.timestamps
    end
  end
end
