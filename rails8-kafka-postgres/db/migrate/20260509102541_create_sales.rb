class CreateSales < ActiveRecord::Migration[8.1]
  def change
    create_table :sales do |t|
      t.decimal :salesamount, precision: 10, scale: 2
      t.datetime :salesdate

      t.timestamps
    end
  end
end
