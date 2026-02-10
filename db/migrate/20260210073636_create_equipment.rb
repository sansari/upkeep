class CreateEquipment < ActiveRecord::Migration[8.1]
  def change
    create_table :equipment do |t|
      t.references :area, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :model_number
      t.string :manufacturer
      t.date :purchase_date
      t.text :notes

      t.timestamps
    end
  end
end
