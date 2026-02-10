class CreateAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :areas do |t|
      t.string :name, null: false
      t.string :icon
      t.boolean :is_default, default: false, null: false
      t.integer :position

      t.timestamps
    end

    add_index :areas, :name, unique: true
  end
end
