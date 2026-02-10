class CreateSupplies < ActiveRecord::Migration[8.1]
  def change
    create_table :supplies do |t|
      t.references :maintenance_task, null: false, foreign_key: true
      t.string :name, null: false
      t.string :purchase_url
      t.integer :quantity_on_hand, default: 0, null: false
      t.integer :quantity_per_use, default: 1, null: false
      t.decimal :unit_price, precision: 10, scale: 2
      t.text :notes

      t.timestamps
    end
  end
end
